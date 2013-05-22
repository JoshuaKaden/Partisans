//
//  GameJoiner.h
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameJoiner;


@protocol GameJoinerDelegate <NSObject>
- (void)gameJoinerDidFinish:(GameJoiner *)gameJoiner;
@optional
- (void)gameJoiner:(GameJoiner *)gameJoiner handleStatusMessage:(NSString *)message;
@end


@interface GameJoiner : NSObject

@property (nonatomic, assign) id <GameJoinerDelegate> delegate;
@property (readonly) BOOL isScanning;
@property (readonly) BOOL hasJoinedGame;

- (void)startScanning;
- (void)stopScanning;

@end
