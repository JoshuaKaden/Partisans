//
//  PlayerEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 4/21/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HauntEnvoy;
@class ImageEnvoy;
@class NSManagedObjectID;
@class Player;

@interface PlayerEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;
@property (nonatomic, strong) NSString *importedObjectString;


@property (nonatomic, strong) NSString *playerName;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) BOOL isNative;
@property (nonatomic, strong) UIColor *favoriteColor;
@property (nonatomic, strong) ImageEnvoy *picture;
@property (nonatomic, assign) BOOL isDefaultPicture;
@property (nonatomic, strong) NSString *peerID;
@property (nonatomic, strong) NSDate *modifiedDate;

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) UIImage *smallImage;

// Search for and return the default player.
+ (PlayerEnvoy *)defaultEnvoy;

+ (PlayerEnvoy *)envoyFromIntramuralID:(NSString *)intramuralID;
+ (PlayerEnvoy *)envoyFromPeerID:(NSString *)peerID;
+ (PlayerEnvoy *)envoyFromManagedObject:(Player *)managedObject;
+ (PlayerEnvoy *)createEnvoyWithPeerID:(NSString *)peerID;

// An alpha list of players on this device.
+ (NSArray *)nativePlayers;
// An alpha list of peer players.
+ (NSArray *)peerPlayers;

- (id)initWithManagedObject:(Player *)managedObject;

- (void)deletePlayer;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end

