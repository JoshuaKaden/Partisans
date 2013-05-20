//
//  SystemMessage.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "SystemMessage.h"

#import "AddGamePlayerOperation.h"
#import "CreateGameOperation.h"
#import "CreatePlayerOperation.h"
#import "GameEnvoy.h"
#import "JSKCommandParcel.h"
#import "JSKDataMiner.h"
#import "JSKPeerController.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "PlayerEnvoy.h"
#import "RemoveGamePlayerOperation.h"
#import "UpdatePlayerOperation.h"

NSString * const JSKNotificationPeerCreated = @"JSKNotificationPeerCreated";
NSString * const JSKNotificationPeerUpdated = @"JSKNotificationPeerUpdated";

NSUInteger const kPartisansMaxPlayers = 10;
NSUInteger const kPartisansMinPlayers = 5;

NSString * const kPartisansNotificationJoinedGame       = @"kPartisansNotificationJoinedGame";
NSString * const kPartisansNotificationGamePlayerAdded  = @"kPartisansNotificationGamePlayerAdded";


@interface SystemMessage () <JSKPeerControllerDelegate>

@property (nonatomic, strong) JSKPeerController *peerController;
@property (nonatomic, strong) NSMutableArray *stash;

- (void)handleResponse:(JSKCommandParcel *)commandParcel;
- (void)handleModifiedDateResponse:(JSKCommandParcel *)response;
- (void)handleGetInfoResponse:(JSKCommandParcel *)response;
- (void)handleJoinGameMessage:(JSKCommandMessage *)message;
- (void)handleJoinGameResponse:(JSKCommandParcel *)response;
- (void)handleIdentification:(JSKCommandMessage *)message;
- (void)handleLeaveGameMessage:(JSKCommandMessage *)message;
- (void)handlePlayerLeftParcel:(JSKCommandParcel *)parcel;

@end



@implementation SystemMessage

@synthesize playerEnvoy = m_playerEnvoy;
@synthesize peerController = m_peerController;
@synthesize gameEnvoy = m_gameEnvoy;
@synthesize stash = m_stash;


- (void)dealloc
{
    [m_peerController setDelegate:nil];
    
    [m_playerEnvoy release];
    [m_peerController release];
    [m_gameEnvoy release];
    [m_stash release];
    
    [super dealloc];
}



#pragma mark - Peer Controller stuff


- (void)handlePlayerLeftParcel:(JSKCommandParcel *)parcel
{
    
}

- (void)handleLeaveGameMessage:(JSKCommandMessage *)message
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:message.from];
    if (!other)
    {
        return;
    }
    BOOL proceed = NO;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (gameEnvoy.host.managedObjectID == [SystemMessage playerEnvoy].managedObjectID)
    {
        // We are hosting a game.
        proceed = YES;
    }
    if (proceed)
    {
        // Make sure this player is in the game.
        if (![gameEnvoy isPlayerInGame:other])
        {
            proceed = NO;
        }
    }
    
    if (!proceed)
    {
        return;
    }
    
    // Remove this player from the game.
    RemoveGamePlayerOperation *op = [[RemoveGamePlayerOperation alloc] initWithEnvoy:other];
    [op setCompletionBlock:^(void) {
//        [SystemMessage broadcastCommandMessage:jskcom]
        // Then, once we've saved, send the game envoy to the new player.
        JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                             to:other.peerID
                                                                           from:self.playerEnvoy.peerID
                                                                   respondingTo:JSKCommandMessageTypeJoinGame];
        GameEnvoy *gameEnvoy = [GameEnvoy envoyFromPlayer:other];
        [response setObject:gameEnvoy];
        [self.peerController sendCommandResponse:response];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGamePlayerAdded object:nil];
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}

- (void)handleIdentification:(JSKCommandMessage *)message
{
    PlayerEnvoy *newEnvoy = [PlayerEnvoy newEnvoyWithPeerID:message.from];
    if (!newEnvoy)
    {
        // Problem with the new envoy; most likely another envoy has the specified peer ID already.
        // Just bail in this case.
        return;
    }
    
    CreatePlayerOperation *op = [[CreatePlayerOperation alloc] initWithEnvoy:newEnvoy];
    [op setCompletionBlock:^(void){
        // Once we've saved, ask for the player's data.
        JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:message.from from:self.playerEnvoy.peerID];
        [self.peerController sendCommandMessage:msg];
        [msg release];
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}



- (void)handleJoinGameResponse:(JSKCommandParcel *)response
{
    if (!response.object)
    {
        return;
    }
    if (![response.object isKindOfClass:[GameEnvoy class]])
    {
        return;
    }
    
    // Save the game locally.
    GameEnvoy *envoy = (GameEnvoy *)response.object;
    CreateGameOperation *op = [[CreateGameOperation alloc] initWithEnvoy:envoy];
    [op setCompletionBlock:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Once the save is done, update our own gameEnvoy property.
            NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
            NSArray *games = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", envoy.intramuralID];
            if (games.count > 0)
            {
                GameEnvoy *updatedEnvoy = [GameEnvoy envoyFromManagedObject:[games objectAtIndex:0]];
                [self setGameEnvoy:updatedEnvoy];
                
                // Also, post a notification that we joined the game.
                [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationJoinedGame object:updatedEnvoy];
            }
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}


- (void)handleJoinGameMessage:(JSKCommandMessage *)message
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:message.from];
    if (!other)
    {
        if (!self.stash)
        {
            NSMutableArray *stash = [[NSMutableArray alloc] initWithCapacity:kPartisansMaxPlayers - 1];
            self.stash = stash;
            [stash release];
        }
        [self.stash addObject:message];
        return;
    }
    BOOL proceed = NO;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (gameEnvoy.host.managedObjectID == [SystemMessage playerEnvoy].managedObjectID)
    {
        // We are hosting a game.
        if (gameEnvoy.players.count < kPartisansMaxPlayers && !gameEnvoy.startDate)
        {
            // The game has room and hasn't yet started.
            // So, let the other player join, and send the game object back!
            proceed = YES;
        }
    }
    if (proceed)
    {
        // Make sure this player isn't already in the game.
        if ([gameEnvoy isPlayerInGame:other])
        {
            proceed = NO;
        }
    }
    
    if (!proceed)
    {
        return;
    }
    
    // Add this player to the game.
    AddGamePlayerOperation *op = [[AddGamePlayerOperation alloc] initWithEnvoy:other];
    [op setCompletionBlock:^(void) {
        // Then, once we've saved, send the game envoy to the new player.
        JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                             to:other.peerID
                                                                           from:self.playerEnvoy.peerID
                                                                   respondingTo:JSKCommandMessageTypeJoinGame];
        GameEnvoy *gameEnvoy = [GameEnvoy envoyFromPlayer:other];
        [response setObject:gameEnvoy];
        [self.peerController sendCommandResponse:response];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGamePlayerAdded object:nil];
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}


- (void)handleResponse:(JSKCommandParcel *)commandParcel
{
    if (!commandParcel.commandParcelType == JSKCommandParcelTypeResponse)
    {
        return;
    }
    
    switch (commandParcel.respondingToType)
    {
        case JSKCommandMessageTypeGetInfo:
            [self handleGetInfoResponse:commandParcel];
            break;
        case JSKCommandMessageTypeGetModifiedDate:
            [self handleModifiedDateResponse:commandParcel];
            break;
        case JSKCommandMessageTypeJoinGame:
            [self handleJoinGameResponse:commandParcel];
            break;
        default:
            break;
    }
}


- (void)handleModifiedDateResponse:(JSKCommandParcel *)response
{
    if (!response.object)
    {
        return;
    }
    if (![response.object isKindOfClass:[NSDate class]])
    {
        return;
    }
    
    NSDate *modifiedDate = (NSDate *)response.object;
    
    // A "regarding" attribute in the response would help narrow the focus of this operation.
    // (For instance, an ID that keys to an entity, or particular attribute on an entity)
    // Like, an ID would mean "the modified date of the picture on the player"
    // Stored in a custom object perhaps, Operation class or something.
    
    // For now assume the modified date of the peer, which is a player.
    // We use this date to determine whether to ask for player info.
    
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:response.from];
    if (!other)
    {
        return;
    }
    if (!modifiedDate || !other.modifiedDate)
    {
        return;
    }
    if ([SystemMessage secondsBetweenDates:other.modifiedDate toDate:modifiedDate] > 0)
    {
        // Apparently new information is available! Let's ask for it.
        JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:response.from from:self.playerEnvoy.peerID];
        [self.peerController sendCommandMessage:msg];
        [msg release];
    }
}


- (void)handleGetInfoResponse:(JSKCommandParcel *)response
{
    NSObject *object = response.object;
    if ([object isKindOfClass:[PlayerEnvoy class]])
    {
        PlayerEnvoy *other = (PlayerEnvoy *)object;
        other.isNative = NO;
        other.isDefault = NO;
        
        // We may already know about this player.
        PlayerEnvoy *localOther = [PlayerEnvoy envoyFromPeerID:other.peerID];
        if (localOther)
        {
            UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:other];
            [op setCompletionBlock:^(void){
                for (JSKCommandMessage *stashedMsg in self.stash)
                {
                    if (stashedMsg.commandMessageType == JSKCommandMessageTypeJoinGame)
                    {
                        if (stashedMsg.from == other.peerID)
                        {
                            [self handleJoinGameMessage:stashedMsg];
                            [self.stash removeObject:stashedMsg];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerUpdated object:other.peerID];
                });
            }];
            NSOperationQueue *queue = [SystemMessage mainQueue];
            [queue addOperation:op];
            [op release];
            return;
        }
        
        CreatePlayerOperation *op = [[CreatePlayerOperation alloc] initWithEnvoy:other];
        [op setCompletionBlock:^(void){
            for (JSKCommandMessage *stashedMsg in self.stash)
            {
                if (stashedMsg.commandMessageType == JSKCommandMessageTypeJoinGame)
                {
                    if (stashedMsg.from == other.peerID)
                    {
                        [self handleJoinGameMessage:stashedMsg];
                        [self.stash removeObject:stashedMsg];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerCreated object:other.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        [op release];
    }
    
    return;
}



- (void)peerController:(JSKPeerController *)peerController connectedToPeer:(NSString *)peerID
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:peerID];
    if (!other)
    {
        // Ask for this peer's info.
        JSKCommandMessage *commandMessage = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:peerID from:self.playerEnvoy.peerID];
        [self.peerController sendCommandMessage:commandMessage];
        [commandMessage release];
    }
}




- (void)peerController:(JSKPeerController *)peerController receivedCommandResponse:(JSKCommandParcel *)commandResponse from:(NSString *)peerID
{
    switch (commandResponse.commandParcelType) {
        case JSKCommandParcelTypeResponse:
            [self handleResponse:commandResponse];
            break;
            
        case JSKCommandParcelTypePlayerJoined:
            [self handleJoinGameResponse:commandResponse];
            break;
            
        case JSKCommandParcelTypePlayerLeft:
            [self handlePlayerLeftParcel:commandResponse];
            break;
            
        case JSKCommandParcelTypeUnknown:
            break;
            
        case JSKCommandParcelType_maxValue:
            break;
    }
}



- (void)peerController:(JSKPeerController *)peerController receivedCommandMessage:(JSKCommandMessage *)commandMessage from:(NSString *)peerID
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:peerID];
    if (!other)
    {
        // Unidentified or unmatched player.
        // This is actually ok if the command is an Identification.
        // An Identification message contains the sender's ID.
        // This is the equivalent of telling someone your name.
        // Once I save that player's ID, and she saves mine, we can communicate.
        if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
        {
            [self handleIdentification:commandMessage];
        }
        return;
    }

    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    JSKCommandMessageType messageType = commandMessage.commandMessageType;
    JSKCommandParcelType parcelType = JSKCommandParcelTypeUnknown;
    NSObject <NSCoding> *responseObject = nil;
    
    switch (messageType)
    {
        case JSKCommandMessageTypeGetInfo:
            parcelType = JSKCommandParcelTypeResponse;
            responseObject = playerEnvoy;
            break;
        case JSKCommandMessageTypeGetModifiedDate:
            parcelType = JSKCommandParcelTypeResponse;
            responseObject = playerEnvoy.modifiedDate;
            break;
        case JSKCommandMessageTypeJoinGame:
            [self handleJoinGameMessage:commandMessage];
            break;
        case JSKCommandMessageTypeIdentification:
        {
            // If not caught above then we already know about this player.
            // Let's get their data.
            JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:commandMessage.from from:self.playerEnvoy.peerID];
            [self.peerController sendCommandMessage:msg];
            [msg release];
            break;
        }
        case JSKCommandMessageTypeLeaveGame:
            [self handleLeaveGameMessage:commandMessage];
            break;
        default:
            break;
    }
    
    if (responseObject)
    {
        JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:parcelType
                                                                         to:peerID
                                                                       from:playerEnvoy.peerID
                                                               respondingTo:messageType];
        [response setObject:responseObject];
        [peerController archiveAndSend:response to:peerID];
        [response release];
    }
}



- (void)peerController:(JSKPeerController *)peerController receivedObject:(NSObject *)object from:(NSString *)peerID
{
    
}




#pragma mark - Class methods

+ (BOOL)isPlayerOnline
{
    SystemMessage *sharedInstance = [self sharedInstance];
    JSKPeerController *peerController = sharedInstance.peerController;
    if (!peerController)
    {
        JSKPeerController *peerController = [[JSKPeerController alloc] init];
        [peerController setDelegate:sharedInstance];
        [peerController setPeerID:sharedInstance.playerEnvoy.peerID];
        [sharedInstance setPeerController:peerController];
        [peerController release];
    }
    if (!peerController.peerID || peerController.peerID.length == 0)
    {
        [peerController setPeerID:sharedInstance.playerEnvoy.peerID];
    }
    return peerController.hasSessionStarted;
}

+ (void)putPlayerOffline
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if (sharedInstance.peerController.hasSessionStarted)
    {
        [sharedInstance.peerController stopSession];
    }
}

+ (void)putPlayerOnline
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if (!sharedInstance.peerController.hasSessionStarted)
    {
        [sharedInstance.peerController startSession];
    }
}

+ (void)resetPeerController
{
    [self putPlayerOffline];
    SystemMessage *sharedInstance = [self sharedInstance];
    [sharedInstance.peerController setDelegate:nil];
    [sharedInstance setPeerController:nil];
}

+ (void)broadcastObject:(NSObject <NSCoding> *)object
{
    if (![self isPlayerOnline])
    {
        return;
    }
    SystemMessage *sharedInstance = [self sharedInstance];
    [sharedInstance.peerController archiveAndBroadcast:object];
}

+ (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType
{
    if (![self isPlayerOnline])
    {
        return;
    }
    SystemMessage *sharedInstance = [self sharedInstance];
    JSKPeerController *peerController = sharedInstance.peerController;
    
    [peerController broadcastCommandMessageType:commandMessageType];
}


+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage
{
    if (![self isPlayerOnline])
    {
        return;
    }
    [[self sharedInstance].peerController sendCommandMessage:commandMessage];
}


+ (void)sendToHost:(JSKCommandMessageType)commandMessageType
{
    if (![self isPlayerOnline])
    {
        return;
    }
    PlayerEnvoy *host = [self sharedInstance].gameEnvoy.host;
    if (!host)
    {
        return;
    }
    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:commandMessageType to:host.peerID from:[self playerEnvoy].peerID];
    JSKPeerController *peerController = [self sharedInstance].peerController;
    [peerController sendCommandMessage:msg];
    [msg release];
}


+ (SystemMessage *)sharedInstance
{
    SystemMessage *singleton = (SystemMessage *)[super sharedInstance];
    return singleton;
}

+ (PlayerEnvoy *)playerEnvoy
{
    return [self sharedInstance].playerEnvoy;
}

+ (GameEnvoy *)gameEnvoy
{
    GameEnvoy *gameEnvoy = [self sharedInstance].gameEnvoy;
    if (gameEnvoy)
    {
        return gameEnvoy;
    }
    // Are we hosting a game?
    PlayerEnvoy *playerEnvoy = [self sharedInstance].playerEnvoy;
    gameEnvoy = [GameEnvoy envoyFromHost:playerEnvoy];
    if (gameEnvoy)
    {
        [[self sharedInstance] setGameEnvoy:gameEnvoy];
        return gameEnvoy;
    }
    // Are we playing a game?
    gameEnvoy = [GameEnvoy envoyFromPlayer:playerEnvoy];
    if (gameEnvoy)
    {
        [[self sharedInstance] setGameEnvoy:gameEnvoy];
        return gameEnvoy;
    }
    
    return nil;
}

+ (BOOL)isSameDay:(NSDate *)firstDate as:(NSDate *)secondDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *firstDateParts = [gregorian components:unitFlags fromDate:firstDate];
    NSDateComponents *secondDateParts = [gregorian components:unitFlags fromDate:secondDate];
    [gregorian release];
    
    if ([firstDateParts day] == [secondDateParts day])
    {
        if ([firstDateParts month] == [secondDateParts month])
        {
            if ([firstDateParts year] == [secondDateParts year])
            {
                return YES;
            }
        }
    }
    
    return NO;
}


+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:fromDate
                                                  toDate:toDate
                                                 options:0];
    [gregorian release];
    
    return [components second];
}


+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}

@end
