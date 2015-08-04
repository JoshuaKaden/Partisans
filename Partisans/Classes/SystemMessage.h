//
//  SystemMessage.h
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

#import <Foundation/Foundation.h>

#import "JSKCommandMessage.h"
#import "JSKCommandParcel.h"
#import "JSKSystemMessage.h"

@class GameDirector;
@class GameEnvoy;
@class PlayerEnvoy;

extern NSString * const kJSKNotificationPeerCreated;
extern NSString * const kJSKNotificationPeerUpdated;

extern NSUInteger const kPartisansMaxPlayers;
extern NSUInteger const kPartisansMinPlayers;
extern NSString * const kPartisansNetServiceName;

extern NSString * const kPartisansNotificationJoinedGame;
extern NSString * const kPartisansNotificationGameChanged;
extern NSString * const kPartisansNotificationConnectedToHost;
extern NSString * const kPartisansNotificationHostAcknowledgement;
extern NSString * const kPartisansNotificationHostReadyToCommunicate;

@interface SystemMessage : JSKSystemMessage

@property (nonatomic, strong) PlayerEnvoy *playerEnvoy;
@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, assign) BOOL isLookingForGame;
@property (nonatomic, assign) BOOL hasSplashBeenShown;
@property (nonatomic, assign) NSUInteger gameCode;

+ (SystemMessage *)sharedInstance;
+ (PlayerEnvoy *)playerEnvoy;
+ (GameEnvoy *)gameEnvoy;
+ (GameDirector *)gameDirector;

+ (BOOL)isHost;
+ (void)browseServers;
+ (void)stopBrowsingServers;
+ (void)requestGameUpdate;
+ (void)leaveGame;
+ (void)reloadGame:(GameEnvoy *)gameEnvoy;
+ (NSString *)serviceName;

+ (UIImage *)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (BOOL)isSameDay:(NSDate *)firstDate as:(NSDate *)secondDate;
+ (NSString *)spellOutNumber:(NSNumber *)number;
+ (NSString *)spellOutInteger:(NSInteger)integer;
+ (NSString *)buildRandomString;
+ (UIView *)rootView;

+ (UIImage *)cachedImage:(NSString *)key;
+ (UIImage *)cachedSmallImage:(NSString *)key;
+ (void)cacheImage:(UIImage *)image key:(NSString *)key;
+ (void)clearImageCache;

+ (PlayerEnvoy *)cachedPlayer:(NSString *)key;
+ (void)cachePlayer:(PlayerEnvoy *)playerEnvoy key:(NSString *)key;
+ (void)clearPlayerCache;

@end
