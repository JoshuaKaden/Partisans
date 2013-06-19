//
//  MissionEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MissionEnvoy.h"

#import "Game.h"
#import "JSKDataMiner.h"
#import "Mission.h"
#import "NSManagedObjectContext+FetchAdditions.h"


@implementation MissionEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize didSucceed = m_didSucceed;
@synthesize isComplete = m_isComplete;
@synthesize missionName = m_missionName;
@synthesize missionNumber = m_missionNumber;
@synthesize teamCount = m_teamCount;
@synthesize gameID = m_gameID;

- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_missionName release];
    [m_gameID release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(Mission *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID    = [[self.managedObjectID URIRepresentation] absoluteString];
        self.didSucceed      = [managedObject.didSucceed boolValue];
        self.isComplete      = [managedObject.isComplete boolValue];
        self.missionName     = managedObject.missionName;
        self.missionNumber   = [managedObject.missionNumber unsignedIntegerValue];
        self.teamCount       = [managedObject.teamCount unsignedIntegerValue];
        self.gameID          = managedObject.game.intramuralID;
    }
    return self;
}


+ (MissionEnvoy *)envoyFromManagedObject:(Mission *)managedObject
{
    MissionEnvoy *envoy = [[[MissionEnvoy alloc] initWithManagedObject:managedObject] autorelease];
    return envoy;
}



- (NSString *)description
{
    NSString *intramuralIDString = self.intramuralID;
    if (!intramuralIDString)
    {
        intramuralIDString = @"";
    }
    
    NSString *managedObjectString = self.managedObjectID.debugDescription;
    if (!managedObjectString)
    {
        managedObjectString = @"";
    }
    
    NSString *missionNameString = self.missionName;
    if (!missionNameString)
    {
        missionNameString = @"";
    }
    
    NSString *gameIDString = self.gameID;
    if (!gameIDString)
    {
        gameIDString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"MissionEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              managedObjectString, @"managedObjectID",
                              [NSNumber numberWithBool:self.didSucceed].description, @"didSucceed",
                              [NSNumber numberWithBool:self.isComplete].description, @"isComplete",
                              missionNameString, @"missionName",
                              [NSNumber numberWithUnsignedInteger:self.missionNumber].description, @"missionNumber",
                              [NSNumber numberWithUnsignedInteger:self.teamCount].description, @"teamCount",
                              gameIDString, @"gameID", nil];
    return descDict.description;
}


#pragma mark - Commits

- (void)commit
{
    [self commitInContext:nil];
}

- (void)commitAndSave
{
    [self commitInContext:nil];
    [JSKDataMiner save];
}

- (void)commitInContext:(NSManagedObjectContext *)context
{
    if (!context)
    {
        context = [JSKDataMiner sharedInstance].mainObjectContext;
    }
    
    Mission *model = nil;
    if (self.managedObjectID)
    {
        model = (Mission *)[context objectWithID:self.managedObjectID];
    }
    
    // This could be an update from the host in which case we have to hook up to the correct via the intramural ID.
    if (!model)
    {
        if (self.intramuralID)
        {
            NSArray *missionList = [context fetchObjectArrayForEntityName:@"Mission" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (missionList.count > 0)
            {
                model = [missionList objectAtIndex:0];
                self.managedObjectID = model.objectID;
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Mission" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.didSucceed = [NSNumber numberWithBool:self.didSucceed];
    model.isComplete = [NSNumber numberWithBool:self.isComplete];
    model.missionName = self.missionName;
    model.missionNumber = [NSNumber numberWithUnsignedInteger:self.missionNumber];
    model.teamCount = [NSNumber numberWithUnsignedInteger:self.teamCount];
    
    
    // Make sure the envoy knows the new managed object ID, if this is an add.
    if (!self.managedObjectID)
    {
        NSError *error = nil;
        [context obtainPermanentIDsForObjects:[NSArray arrayWithObject:model] error:&error];
        if (!error)
        {
            self.managedObjectID = model.objectID;
        }
    }
    
    if (!self.intramuralID)
    {
        self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        model.intramuralID = self.intramuralID;
    }
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    
    [aCoder encodeBool:self.didSucceed forKey:@"didSucceed"];
    [aCoder encodeBool:self.isComplete forKey:@"isComplete"];
    [aCoder encodeObject:self.missionName forKey:@"missionName"];
    [aCoder encodeInteger:self.missionNumber forKey:@"missionNumber"];
    [aCoder encodeInteger:self.teamCount forKey:@"teamCount"];
    [aCoder encodeObject:self.gameID forKey:@"gameID"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.didSucceed = [aDecoder decodeBoolForKey:@"didSucceed"];
        self.isComplete = [aDecoder decodeBoolForKey:@"isComplete"];
        self.missionName = [aDecoder decodeObjectForKey:@"missionName"];
        self.missionNumber = [aDecoder decodeIntegerForKey:@"missionNumber"];
        self.teamCount = [aDecoder decodeIntegerForKey:@"teamCount"];
        self.gameID = [aDecoder decodeObjectForKey:@"gameID"];
    }
    
    return self;
}


@end
