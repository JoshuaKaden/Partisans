//
//  NetHandler.h
//  Partisans
//
//  Created by Joshua Kaden on 8/4/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSKCommandParcel;
@class GameEnvoy;
@class PlayerEnvoy;

@interface NetHandler : NSObject

@property (nonatomic, readonly) GameEnvoy *gameEnvoy;
@property (nonatomic, readonly) NSString *myPeerID;
@property (nonatomic, readonly) PlayerEnvoy *playerEnvoy;

- (void)sendDigestTo:(NSString *)toPeerID;

/** This will check the local data and ask for new data as needed. */
- (void)processDigest:(NSDictionary *)digest;

- (void)handlePlayerUpdate:(JSKCommandParcel *)parcel;

@end
