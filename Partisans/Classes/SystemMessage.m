//
//  SystemMessage.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//
//  Copyright (c) 2013, Joshua Kaden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SystemMessage.h"

#import "AddGamePlayerOperation.h"
#import "AppDelegate.h"
#import "CoordinatorVote.h"
#import "CreateGameOperation.h"
#import "GameDirector.h"
#import "GameEnvoy.h"
#import "GamePrecis.h"
#import "JSKCommandMessage.h"
#import "JSKCommandParcel.h"
#import "JSKDataMiner.h"
#import "MissionEnvoy.h"
#import "NetHost.h"
#import "NetPlayer.h"
#import "NetworkManager.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "PlayerEnvoy.h"
#import "RemoveGamePlayerOperation.h"
#import "RoundEnvoy.h"
#import "ServerBrowser.h"
#import "ServerBrowserDelegate.h"
#import "UpdateGameOperation.h"
#import "UpdatePlayerOperation.h"
#import "UpdateEnvoysOperation.h"
#import "VoteEnvoy.h"


const BOOL kIsDebugOn = YES;

NSString * const kJSKNotificationPeerCreated = @"kJSKNotificationPeerCreated";
NSString * const kJSKNotificationPeerUpdated = @"kJSKNotificationPeerUpdated";

NSUInteger const kPartisansMaxPlayers = 10;
NSUInteger const kPartisansMinPlayers = 5;

NSString * const kPartisansNotificationJoinedGame  = @"kPartisansNotificationJoinedGame";
NSString * const kPartisansNotificationGameChanged = @"kPartisansNotificationGameChanged";
NSString * const kPartisansNotificationConnectedToHost = @"kPartisansNotificationConnectedToHost";
NSString * const kPartisansNotificationHostAcknowledgement = @"kPartisansNotificationHostAcknowledgement";
NSString * const kPartisansNotificationHostReadyToCommunicate = @"kPartisansNotificationHostReadyToCommunicate";

NSString * const kPartisansNetServiceName = @"ThoroughlyRandomServiceNameForPartisans";


@interface SystemMessage () <ServerBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *stash;
@property (nonatomic, strong) NSMutableArray *peerIDs;
@property (nonatomic, strong) NSString *hostPeerID;
@property (nonatomic, strong) ServerBrowser *serverBrowser;
@property (nonatomic, strong) GameDirector *gameDirector;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSCache *playerCache;

@end



@implementation SystemMessage

- (void)dealloc
{
    [_serverBrowser setDelegate:nil];
}

- (void)reloadGame:(GameEnvoy *)gameEnvoy
{
    if (!gameEnvoy)
    {
        gameEnvoy = self.gameEnvoy;
    }
    GameEnvoy *updatedGame = [GameEnvoy envoyFromIntramuralID:gameEnvoy.intramuralID];
    [self setGameEnvoy:updatedGame];
}


#pragma mark - Image Cache

+ (UIImage *)cachedImage:(NSString *)key
{
    UIImage *returnValue = nil;
    NSCache *cache = [self sharedInstance].imageCache;
    if (!cache)
    {
        cache = [[NSCache alloc] init];
        [self sharedInstance].imageCache = cache;
    }
    else
    {
        returnValue = [cache objectForKey:key];
    }
    return returnValue;
}

+ (UIImage *)cachedSmallImage:(NSString *)key
{
    UIImage *returnValue = nil;
    NSCache *cache = [self sharedInstance].imageCache;
    if (!cache)
    {
        cache = [[NSCache alloc] init];
        [self sharedInstance].imageCache = cache;
    }
    else
    {
        NSString *smallKey = [[NSString alloc] initWithFormat:@"%@-small", key];
        returnValue = [cache objectForKey:smallKey];
    }
    return returnValue;
}

+ (void)cacheImage:(UIImage *)image key:(NSString *)key
{
    NSString *smallKey = [[NSString alloc] initWithFormat:@"%@-small", key];
    UIImage *smallerImage = [self imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(50.0, 50.0)];
    NSCache *cache = [self sharedInstance].imageCache;
    if (!cache)
    {
        NSCache *newCache = [[NSCache alloc] init];
        [self sharedInstance].imageCache = newCache;
        cache = [self sharedInstance].imageCache;
    }
    [cache setObject:image forKey:key];
    [cache setObject:smallerImage forKey:smallKey];
}

+ (void)clearImageCache
{
    NSCache *cache = [self sharedInstance].imageCache;
    [cache removeAllObjects];
}



#pragma mark - Player Cache

+ (PlayerEnvoy *)cachedPlayer:(NSString *)key
{
    PlayerEnvoy *returnValue = nil;
    NSCache *cache = [self sharedInstance].playerCache;
    if (!cache)
    {
        cache = [[NSCache alloc] init];
        [self sharedInstance].playerCache = cache;
    }
    else
    {
        returnValue = [cache objectForKey:key];
    }
    return returnValue;
}

+ (void)cachePlayer:(PlayerEnvoy *)playerEnvoy key:(NSString *)key
{
    NSCache *cache = [self sharedInstance].playerCache;
    [cache setObject:playerEnvoy forKey:key];
}

+ (void)clearPlayerCache
{
    NSCache *cache = [self sharedInstance].playerCache;
    [cache removeAllObjects];
}




#pragma mark - Host



#pragma mark - Player




#pragma mark - Player / Host


#pragma mark - ServerBrowser delegate

- (void)updateServerList
{
    NSString *serviceName = [SystemMessage serviceName];
    NSArray *servers = self.serverBrowser.servers;
    for (NSNetService *service in servers) {
        if ([service.name isEqualToString:serviceName]) {
            [NetworkManager setupNetPlayerWithService:service];
            break;
        }
    }
}

#pragma mark - Class methods

+ (void)leaveGame
{
    SystemMessage *sharedInstance = [self sharedInstance];
    GameEnvoy *gameEnvoy = sharedInstance.gameEnvoy;
    [gameEnvoy deleteGame];
    [sharedInstance setGameEnvoy:nil];
}

+ (UIView *)rootView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.window.rootViewController.view;
}


+ (void)browseServers
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if (sharedInstance.serverBrowser) {
        [self stopBrowsingServers];
    }
    ServerBrowser *serverBrowser = [[ServerBrowser alloc] init];
    [serverBrowser setDelegate:sharedInstance];
    sharedInstance.serverBrowser = serverBrowser;
    [sharedInstance.serverBrowser start];
}


+ (void)stopBrowsingServers
{
    SystemMessage *sharedInstance = [self sharedInstance];
    [sharedInstance.serverBrowser stop];
    [sharedInstance.serverBrowser setDelegate:nil];
    sharedInstance.serverBrowser = nil;
}

+ (void)requestGameUpdate
{
    if (![NetworkManager isPlayerOnline]) {
        // This begins a chain reaction that will end up with us requesting a game update (in processDigest:).
        [NetworkManager putPlayerOnline];
        return;
    }
    SystemMessage *sharedInstance = [self sharedInstance];
    GameEnvoy *gameEnvoy = sharedInstance.gameEnvoy;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:gameEnvoy.modifiedDate, @"modifiedDate", @"Game", @"entity", nil];
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeModifiedDate
                                                                   to:sharedInstance.hostPeerID
                                                                 from:sharedInstance.playerEnvoy.peerID
                                                               object:dictionary];
    [NetworkManager sendCommandParcel:parcel shouldAwaitResponse:NO];
}

+ (BOOL)isHost
{
    GameEnvoy *gameEnvoy = [self gameEnvoy];
    if (!gameEnvoy) {
        return NO;
    }
    PlayerEnvoy *playerEnvoy = [self playerEnvoy];
    PlayerEnvoy *host = [gameEnvoy host];
    if ([playerEnvoy.intramuralID isEqualToString:host.intramuralID]) {
        return YES;
    } else {
        return NO;
    }
}



+ (NSString *)serviceName
{
    NSUInteger gameCode = [self sharedInstance].gameCode;
    if (gameCode == 0) {
        GameEnvoy *gameEnvoy = [self sharedInstance].gameEnvoy;
        gameCode = gameEnvoy.gameCode;
        [self sharedInstance].gameCode = gameCode;
    }
    NSString *serviceName = [NSString stringWithFormat:@"%@%@", kPartisansNetServiceName, @(gameCode)];
    return serviceName;
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

+ (GameDirector *)gameDirector
{
    if (![self sharedInstance].gameEnvoy)
    {
        return nil;
    }
    GameDirector *gameDirector = [self sharedInstance].gameDirector;
    if (gameDirector)
    {
        return gameDirector;
    }
    gameDirector = [[GameDirector alloc] init];
    [[self sharedInstance] setGameDirector:gameDirector];
    
    return [self sharedInstance].gameDirector;
}




+ (NSString *)buildRandomString
{
    CFUUIDRef udid = CFUUIDCreate(NULL);
    NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
    NSString *returnValue = [NSString stringWithString:udidString];
    CFRelease(udid);
    return returnValue;
}


+ (NSString *)spellOutNumber:(NSNumber *)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    NSString *returnValue = [formatter stringFromNumber:number];
    return returnValue;
}

+ (NSString *)spellOutInteger:(NSInteger)integer
{
    return [self spellOutNumber:[NSNumber numberWithInteger:integer]];
}


+ (BOOL)isSameDay:(NSDate *)firstDate as:(NSDate *)secondDate
{
    return [firstDate isEqualToDate:secondDate];
}


+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    return [toDate timeIntervalSinceDate:fromDate];
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
        bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
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

+ (void)reloadGame:(GameEnvoy *)gameEnvoy
{
    [[self sharedInstance] reloadGame:gameEnvoy];
}

@end
