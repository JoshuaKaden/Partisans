//
//  RoundEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 6/20/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectID;
@class Round;
@class RoundEnvoy;

@interface RoundEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;

@property (nonatomic, assign) NSUInteger roundNumber;
@property (nonatomic, assign) NSUInteger missionNumber;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *coordinatorID;

+ (RoundEnvoy *)envoyFromManagedObject:(Round *)managedObject;

- (id)initWithManagedObject:(Round *)managedObject;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
