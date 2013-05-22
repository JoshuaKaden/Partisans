//
//  JSKPeerController.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Gamekit/Gamekit.h>

#import "JSKCommandMessage.h"
#import "JSKCommandParcel.h"

@class JSKPeerController;



@protocol JSKPeerControllerDelegate <NSObject>
@optional
- (void)peerController:(JSKPeerController *)peerController connectedToPeer:(NSString *)peerID;
- (void)peerController:(JSKPeerController *)peerController receivedCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)peerController:(JSKPeerController *)peerController receivedCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)peerController:(JSKPeerController *)peerController receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(JSKCommandMessage *)commandMessage;
- (void)peerController:(JSKPeerController *)peerController receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingToObject:(NSObject *)respondingToObject;
- (void)peerController:(JSKPeerController *)peerController receivedObject:(NSObject <NSCoding> *)object from:peerID;
//- (NSString *)peerNameFromID:(NSString *)peerID;
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
- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)sendObject:(NSObject <NSCoding> *)object to:(NSString *)peerID;

// For this to work, please ensure that the supplied "object" has an NSString "responseKey" attribute.
- (void)sendObject:(NSObject <NSCoding> *)object to:(NSString *)peerID shouldAwaitResponse:(BOOL)shouldAwaitResponse;

- (void)broadcastCommandMessageType:(JSKCommandMessageType)commandMessageType;
//- (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType toPeerIDs:(NSArray *)peerIDs;

- (void)archiveAndSend:(NSObject <NSCoding> *)object to:(NSString *)to;
- (void)archiveAndBroadcast:(NSObject <NSCoding> *)object;

- (void)resetPeerID;


// Wish list
//- (void)sendCommandMessage:(CommandMessage *)commandMessage completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;


@end
