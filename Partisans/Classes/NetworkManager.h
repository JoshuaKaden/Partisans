//
//  NetworkManager.h
//  Partisans
//
//  Created by Joshua Kaden on 8/3/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKCommandMessage.h"

@class JSKCommandParcel;

@interface NetworkManager : NSObject

+ (BOOL)isPlayerOnline;
+ (void)putPlayerOnline;
+ (void)putPlayerOffline;
+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
+ (void)sendCommandParcel:(JSKCommandParcel *)parcel shouldAwaitResponse:(BOOL)shouldAwaitResponse;
+ (void)sendToHost:(JSKCommandMessageType)commandMessageType shouldAwaitResponse:(BOOL)shouldAwaitResponse;
+ (void)sendParcelToPlayers:(JSKCommandParcel *)parcel;
+ (void)setupNetPlayerWithService:(NSNetService *)service;

+ (void)askToJoinGame;
+ (void)askToJoinGameHostedBy:(NSString *)hostID;

@end
