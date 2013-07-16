//
//  GameDirector.h
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameDirector : NSObject

- (void)startGame;
- (void)startMission;
- (void)startNewRound;
- (void)sendGameUpdateTo:(NSString *)peerID modifiedDate:(NSDate *)modifiedDate shouldSendAllData:(BOOL)shouldSendAllData;

@end
