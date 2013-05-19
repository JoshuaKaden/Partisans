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
#import "JSKCommandResponse.h"
#import "JSKDataMiner.h"
#import "JSKPeerController.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "PlayerEnvoy.h"
#import "UpdatePlayerOperation.h"

NSString * const JSKNotificationPeerCreated = @"JSKNotificationPeerCreated";
NSString * const JSKNotificationPeerUpdated= @"JSKNotificationPeerUpdated";

NSUInteger const kPartisansMaxPlayers = 10;
NSUInteger const kPartisansMinPlayers = 5;

NSString * const kPartisansNotificationJoinedGame = @"kPartisansNotificationJoinedGame";


@interface SystemMessage () <JSKPeerControllerDelegate>

@property (nonatomic, strong) JSKPeerController *peerController;
@property (nonatomic, strong) NSMutableArray *stash;

- (void)handleAcknowledgement:(JSKCommandResponse *)commandResponse;
- (void)handleModifiedDateResponse:(JSKCommandResponse *)response;
- (void)handleGetInfoResponse:(JSKCommandResponse *)response;
- (void)handleJoinGameMessage:(JSKCommandMessage *)message;
- (void)handleJoinGameResponse:(JSKCommandResponse *)response;
- (void)handleIdentification:(JSKCommandMessage *)message;

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



- (void)handleJoinGameResponse:(JSKCommandResponse *)response
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
        // Once the save is done, update our own gameEnvoy property.
        NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
        NSArray *games = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", envoy.intramuralID];
        if (games.count > 0)
        {
            GameEnvoy *updatedEnvoy = [GameEnvoy envoyFromManagedObject:[games objectAtIndex:0]];
            [self setGameEnvoy:updatedEnvoy];
            
            // Also, post a notification that we joined the game.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationJoinedGame object:updatedEnvoy];
            });
        }
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
    if (!proceed)
    {
        return;
    }
    
    // Add this player to the game.
    AddGamePlayerOperation *op = [[AddGamePlayerOperation alloc] initWithEnvoy:other];
    [op setCompletionBlock:^(void) {
        // Then, once we've saved, send the game envoy to the new player.
        JSKCommandResponse *response = [[JSKCommandResponse alloc] initWithType:JSKCommandResponseTypeAcknowledge
                                                                             to:other.peerID
                                                                           from:self.playerEnvoy.peerID
                                                                   respondingTo:JSKCommandMessageTypeJoinGame];
        [response setObject:gameEnvoy];
        [self.peerController sendCommandResponse:response];
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}


- (void)handleAcknowledgement:(JSKCommandResponse *)commandResponse
{
    if (!commandResponse.commandResponseType == JSKCommandResponseTypeAcknowledge)
    {
        return;
    }
    
    switch (commandResponse.respondingToType)
    {
        case JSKCommandMessageTypeGetInfo:
            [self handleGetInfoResponse:commandResponse];
            break;
        case JSKCommandMessageTypeGetModifiedDate:
            [self handleModifiedDateResponse:commandResponse];
            break;
        default:
            break;
    }
}


- (void)handleModifiedDateResponse:(JSKCommandResponse *)response
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


- (void)handleGetInfoResponse:(JSKCommandResponse *)response
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




- (void)peerController:(JSKPeerController *)peerController receivedCommandResponse:(JSKCommandResponse *)commandResponse from:(NSString *)peerID
{
    switch (commandResponse.commandResponseType) {
        case JSKCommandResponseTypeAcknowledge:
            [self handleAcknowledgement:commandResponse];
            break;
            
        case JSKCommandResponseType_maxValue:
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
    NSObject <NSCoding> *responseObject = nil;
    
    switch (messageType)
    {
        case JSKCommandMessageTypeGetInfo:
            responseObject = playerEnvoy;
            break;
        case JSKCommandMessageTypeGetModifiedDate:
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
        default:
            break;
    }
    
    if (responseObject)
    {
        JSKCommandResponse *response = [[JSKCommandResponse alloc] initWithType:JSKCommandResponseTypeAcknowledge
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
    // Let's see if there's one attached to the player.
    PlayerEnvoy *playerEnvoy = [self sharedInstance].playerEnvoy;
    gameEnvoy = [GameEnvoy envoyFromHost:playerEnvoy];
    if (gameEnvoy)
    {
        [[self sharedInstance] setGameEnvoy:gameEnvoy];
    }
    return gameEnvoy;
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
