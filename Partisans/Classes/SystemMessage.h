//
//  SystemMessage.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSKCommandMessage.h"
#import "JSKCommandParcel.h"
#import "JSKSystemMessage.h"

@class GameEnvoy;
@class PlayerEnvoy;

extern NSString * const JSKNotificationPeerCreated;
extern NSString * const JSKNotificationPeerUpdated;

extern NSUInteger const kPartisansMaxPlayers;
extern NSUInteger const kPartisansMinPlayers;
extern NSString * const kPartisansNetServiceName;

extern NSString * const kPartisansNotificationJoinedGame;
extern NSString * const kPartisansNotificationGameChanged;
extern NSString * const kPartisansNotificationConnectedToHost;

@interface SystemMessage : JSKSystemMessage

@property (nonatomic, strong) PlayerEnvoy *playerEnvoy;
@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, assign) BOOL isLookingForGame;

+ (SystemMessage *)sharedInstance;
+ (PlayerEnvoy *)playerEnvoy;
+ (GameEnvoy *)gameEnvoy;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (BOOL)isSameDay:(NSDate *)firstDate as:(NSDate *)secondDate;

+ (BOOL)isPlayerOnline;
+ (void)putPlayerOnline;
+ (void)putPlayerOffline;
+ (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType;
+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage;
+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
+ (void)sendCommandParcel:(JSKCommandParcel *)parcel shouldAwaitResponse:(BOOL)shouldAwaitResponse;
+ (void)sendToHost:(JSKCommandMessageType)commandMessageType shouldAwaitResponse:(BOOL)shouldAwaitResponse;
+ (void)sendParcelToPlayers:(JSKCommandParcel *)parcel;
+ (BOOL)isHost;
+ (void)askToJoinGame;
+ (BOOL)connectToService:(NSNetService *)service;

@end
