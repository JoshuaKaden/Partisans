//
//  VoteEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectID;
@class Vote;

@interface VoteEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;

@property (nonatomic, assign) BOOL isCast;
@property (nonatomic, assign) BOOL isYea;
@property (nonatomic, strong) NSString *roundID;
@property (nonatomic, strong) NSString *playerID;

+ (VoteEnvoy *)envoyFromManagedObject:(Vote *)managedObject;

- (id)initWithManagedObject:(Vote *)managedObject;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
