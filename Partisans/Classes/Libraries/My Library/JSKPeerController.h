//
//  JSKPeerController.h
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Gamekit/Gamekit.h>

#import "JSKCommandMessage.h"
#import "JSKCommandResponse.h"

@class JSKPeerController;



@protocol JSKPeerControllerDelegate <NSObject>
@optional
- (void)peerController:(JSKPeerController *)peerController connectedToPeer:(NSString *)peerID;
- (void)peerController:(JSKPeerController *)peerController receivedCommandMessage:(JSKCommandMessage *)commandMessage from:(NSString *)peerID;
- (void)peerController:(JSKPeerController *)peerController receivedCommandResponse:(JSKCommandResponse *)commandResponse from:(NSString *)peerID;
- (void)peerController:(JSKPeerController *)peerController receivedObject:(NSObject *)object from:(NSString *)peerID;
- (NSString *)peerNameFromID:(NSString *)peerID;
- (void)peerControllerQueueHasEmptied:(JSKPeerController *)peerController;
@end



extern const NSUInteger PeerMessageSizeLimit;


@interface JSKPeerController : NSObject <GKSessionDelegate>

@property (nonatomic, assign) id <JSKPeerControllerDelegate> delegate;
@property (nonatomic, strong) NSString *peerID;
//@property (readonly, nonatomic, strong) NSString *myPeerID;
@property (readonly) BOOL hasSessionStarted;

- (void)startSession;
- (void)stopSession;

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)sendCommandResponse:(JSKCommandResponse *)commandResponse;
- (void)broadcastCommandMessageType:(JSKCommandMessageType)commandMessageType;
- (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType toPeerIDs:(NSArray *)peerIDs;

- (void)archiveAndSend:(NSObject <NSCoding> *)object to:(NSString *)to;
- (void)archiveAndBroadcast:(NSObject <NSCoding> *)object;

- (void)resetPeerID;


// Wish list
//- (void)sendCommandMessage:(CommandMessage *)commandMessage completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;


@end
