//
//  GamePlayerEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 5/18/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GamePlayer;
@class NSManagedObjectID;

@interface GamePlayerEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;
@property (nonatomic, strong) NSString *importedObjectString;

@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, assign) BOOL isOperative;
@property (nonatomic, strong) NSString *playerID;
@property (nonatomic, strong) NSString *gameID;

+ (GamePlayerEnvoy *)envoyFromManagedObject:(GamePlayer *)managedObject;

- (id)initWithManagedObject:(GamePlayer *)managedObject;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
