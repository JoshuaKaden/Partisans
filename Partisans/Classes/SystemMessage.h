//
//  SystemMessage.h
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKCommandMessage.h"
#import "JSKSystemMessage.h"

@class PlayerEnvoy;

@interface SystemMessage : JSKSystemMessage

@property (nonatomic, strong) PlayerEnvoy *playerEnvoy;

+ (SystemMessage *)sharedInstance;
+ (PlayerEnvoy *)playerEnvoy;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (BOOL)isSameDay:(NSDate *)firstDate as:(NSDate *)secondDate;

+ (BOOL)isPlayerOnline;
+ (void)putPlayerOnline;
+ (void)putPlayerOffline;
+ (void)resetPeerController;
+ (void)broadcastObject:(NSObject <NSCoding> *)object;
+ (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType;

@end
