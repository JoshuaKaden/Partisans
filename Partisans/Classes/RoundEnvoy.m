//
//  RoundEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 6/20/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "RoundEnvoy.h"

#import "Game.h"
#import "GamePlayer.h"
#import "JSKDataMiner.h"
#import "Mission.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "Round.h"
#import "SystemMessage.h"


@implementation RoundEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize roundNumber = m_roundNumber;
@synthesize missionNumber = m_missionNumber;
@synthesize gameID = m_gameID;
@synthesize coordinatorID = m_coordinatorID;

- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_gameID release];
    [m_coordinatorID release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(Round *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID    = [[self.managedObjectID URIRepresentation] absoluteString];
        self.roundNumber     = [managedObject.roundNumber unsignedIntegerValue];
        self.missionNumber   = [managedObject.mission.missionNumber unsignedIntegerValue];
        self.gameID          = managedObject.game.intramuralID;
        self.coordinatorID   = managedObject.leader.player.intramuralID;
    }
    return self;
}


+ (RoundEnvoy *)envoyFromManagedObject:(Round *)managedObject
{
    RoundEnvoy *envoy = [[[RoundEnvoy alloc] initWithManagedObject:managedObject] autorelease];
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
        
    NSString *gameIDString = self.gameID;
    if (!gameIDString)
    {
        gameIDString = @"";
    }
    
    NSString *coordinatorIDString = self.coordinatorID;
    if (!coordinatorIDString)
    {
        coordinatorIDString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"RoundEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              managedObjectString, @"managedObjectID",
                              [NSNumber numberWithUnsignedInteger:self.missionNumber].description, @"missionNumber",
                              [NSNumber numberWithUnsignedInteger:self.roundNumber].description, @"roundNumber",
                              gameIDString, @"gameID",
                              coordinatorIDString, @"coordinatorID", nil];
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
    
    Round *model = nil;
    if (self.managedObjectID)
    {
        model = (Round *)[context objectWithID:self.managedObjectID];
    }
    
    // This could be an update from the host in which case we have to hook up to the correct via the intramural ID.
    if (!model)
    {
        if (self.intramuralID)
        {
            NSArray *list = [context fetchObjectArrayForEntityName:@"Round" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (list.count > 0)
            {
                model = [list objectAtIndex:0];
                self.managedObjectID = model.objectID;
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Round" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.roundNumber = [NSNumber numberWithUnsignedInteger:self.roundNumber];
    
    
    // The game.
    if (!model.game)
    {
        NSArray *list = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", self.gameID];
        model.game = [list objectAtIndex:0];
    }
    
    
    // The mission.
    if (!model.mission)
    {
        for (Mission *mission in model.game.missions)
        {
            if ([mission.missionNumber isEqualToNumber:[NSNumber numberWithUnsignedInteger:self.missionNumber]])
            {
                model.mission = mission;
                break;
            }
        }
    }
    
    // The coordinator.
    if (!model.leader)
    {
        for (GamePlayer *gamePlayer in model.game.gamePlayers)
        {
            if ([gamePlayer.player.intramuralID isEqualToString:self.coordinatorID])
            {
                model.leader = gamePlayer;
                break;
            }
        }
    }
    
    
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
    
    [aCoder encodeInteger:self.missionNumber forKey:@"missionNumber"];
    [aCoder encodeInteger:self.roundNumber forKey:@"roundNumber"];
    [aCoder encodeObject:self.gameID forKey:@"gameID"];
    [aCoder encodeObject:self.coordinatorID forKey:@"coordinatorID"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.missionNumber = [aDecoder decodeIntegerForKey:@"missionNumber"];
        self.roundNumber = [aDecoder decodeIntegerForKey:@"roundNumber"];
        self.gameID = [aDecoder decodeObjectForKey:@"gameID"];
        self.coordinatorID = [aDecoder decodeObjectForKey:@"coordinatorID"];
    }
    
    return self;
}


@end
