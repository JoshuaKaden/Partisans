//
//  MissionEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Mission;
@class NSManagedObjectID;

@interface MissionEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;

@property (nonatomic, assign) BOOL didSucceed;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, strong) NSString *missionName;
@property (nonatomic, assign) NSUInteger missionNumber;
@property (nonatomic, assign) NSUInteger teamCount;
@property (nonatomic, strong) NSString *gameID;

+ (MissionEnvoy *)envoyFromManagedObject:(Mission *)managedObject;

- (id)initWithManagedObject:(Mission *)managedObject;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
