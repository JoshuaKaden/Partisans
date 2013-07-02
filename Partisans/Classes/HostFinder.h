//
//  HostFinder.h
//  Partisans
//
//  Created by Joshua Kaden on 6/29/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HostFinder;


@protocol HostFinderDelegate <NSObject>

- (void)hostFinder:(HostFinder *)hostFinder isConnectedToHost:(NSString *)hostPeerID;

@optional
- (void)hostFinder:(HostFinder *)hostFinder handleStatusMessage:(NSString *)message;
- (void)hostFinderTimerFired:(HostFinder *)hostFinder;

@end


@interface HostFinder : NSObject

@property (nonatomic, assign) id <HostFinderDelegate> delegate;
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) NSString *hostPeerID;
@property (nonatomic, assign) double timerInterval;

- (void)connect;
- (void)stop;

@end
