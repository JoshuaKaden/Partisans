//
//  MissionEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MissionEnvoy.h"

#import "Game.h"
#import "GamePlayer.h"
#import "JSKDataMiner.h"
#import "Mission.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "PlayerEnvoy.h"


@interface MissionEnvoy ()

@property (nonatomic, strong) NSString *coordinatorID;
@property (nonatomic, strong) NSArray *teamMemberIDs;
@property (nonatomic, strong) NSArray *saboteurIDs;
@property (nonatomic, strong) NSArray *contributeurIDs;

- (void)loadCoordinator;
- (void)loadTeamMemberIDs;
- (void)loadSaboteurIDs;
- (void)loadContributeurIDs;

@end


@implementation MissionEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize hasStarted = m_hasStarted;
@synthesize didSucceed = m_didSucceed;
@synthesize isComplete = m_isComplete;
@synthesize missionName = m_missionName;
@synthesize missionNumber = m_missionNumber;
@synthesize teamCount = m_teamCount;
@synthesize gameID = m_gameID;
@synthesize coordinator = m_coordinator;
@synthesize coordinatorID = m_coordinatorID;
@synthesize teamMemberIDs = m_teamMemberIDs;
@synthesize saboteurIDs = m_saboteurIDs;
@synthesize contributeurIDs = m_contributeurIDs;

- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_missionName release];
    [m_gameID release];
    [m_coordinator release];
    [m_coordinatorID release];
    [m_teamMemberIDs release];
    [m_saboteurIDs release];
    [m_contributeurIDs release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(Mission *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID    = managedObject.intramuralID;
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        }
        self.hasStarted      = [managedObject.hasStarted boolValue];
        self.didSucceed      = [managedObject.didSucceed boolValue];
        self.isComplete      = [managedObject.isComplete boolValue];
        self.missionName     = managedObject.missionName;
        self.missionNumber   = [managedObject.missionNumber unsignedIntegerValue];
        self.teamCount       = [managedObject.teamCount unsignedIntegerValue];
        self.gameID          = managedObject.game.intramuralID;
        
        [self loadCoordinator];
        [self loadTeamMemberIDs];
        [self loadSaboteurIDs];
        [self loadContributeurIDs];
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
    
    NSString *coordinatorIDString = self.coordinatorID;
    if (!coordinatorIDString)
    {
        coordinatorIDString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"MissionEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              managedObjectString, @"managedObjectID",
                              [NSNumber numberWithBool:self.hasStarted].description, @"hasStarted",
                              [NSNumber numberWithBool:self.didSucceed].description, @"didSucceed",
                              [NSNumber numberWithBool:self.isComplete].description, @"isComplete",
                              missionNameString, @"missionName",
                              [NSNumber numberWithUnsignedInteger:self.missionNumber].description, @"missionNumber",
                              [NSNumber numberWithUnsignedInteger:self.teamCount].description, @"teamCount",
                              gameIDString, @"gameID",
                              coordinatorIDString, @"coordinatorID",
                              self.teamMemberIDs, @"teamMemberIDs",
                              self.saboteurIDs, @"saboteurIDs",
                              self.contributeurIDs, @"contributeurIDs", nil];
    return descDict.description;
}


- (void)loadCoordinator
{
    if (!self.managedObjectID)
    {
        return;
    }
    NSManagedObjectContext *context = [JSKDataMiner sharedInstance].mainObjectContext;
    Mission *mission = (Mission *)[context objectWithID:self.managedObjectID];
    if (mission.coordinator)
    {
        self.coordinator = [PlayerEnvoy envoyFromManagedObject:mission.coordinator.player];
        self.coordinatorID = self.coordinator.intramuralID;
    }
}

- (NSString *)coordinatorID
{
    if (!m_coordinatorID)
    {
        if (self.coordinator)
        {
            self.coordinatorID = self.coordinator.intramuralID;
        }
    }
    return m_coordinatorID;
}


#pragma mark - Team Members

- (void)applyTeamMembers:(NSArray *)teamMembers
{
    self.teamMemberIDs = [teamMembers valueForKey:@"intramuralID"];
}

- (NSArray *)teamMembers
{
    if (!self.teamMemberIDs)
    {
        [self loadTeamMemberIDs];
    }
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.teamMemberIDs.count];
    for (NSString *intramuralID in self.teamMemberIDs)
    {
        [list addObject:[PlayerEnvoy envoyFromIntramuralID:intramuralID]];
    }
    NSArray *returnValue = [NSArray arrayWithArray:list];
    [list release];
    return returnValue;
}

- (void)loadTeamMemberIDs
{
    if (!self.managedObjectID)
    {
        return;
    }
    NSManagedObjectContext *context = [JSKDataMiner sharedInstance].mainObjectContext;
    Mission *mission = (Mission *)[context objectWithID:self.managedObjectID];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:mission.teamMembers.count];
    for (GamePlayer *gamePlayer in mission.teamMembers)
    {
        [list addObject:gamePlayer.player.intramuralID];
    }
    self.teamMemberIDs = [NSArray arrayWithArray:list];
    [list release];
}

- (BOOL)isPlayerOnTeam:(PlayerEnvoy *)playerEnvoy
{
    BOOL returnValue = NO;
    if (!self.teamMemberIDs)
    {
        [self loadTeamMemberIDs];
    }
    for (NSString *intramuralID in self.teamMemberIDs)
    {
        if ([intramuralID isEqualToString:playerEnvoy.intramuralID])
        {
            returnValue = YES;
            break;
        }
    }
    return returnValue;
}

- (BOOL)hasPlayerPerformed:(PlayerEnvoy *)playerEnvoy
{
    BOOL returnValue = NO;
    if (!self.saboteurIDs)
    {
        [self loadSaboteurIDs];
    }
    for (NSString *intramuralID in self.saboteurIDs)
    {
        if ([intramuralID isEqualToString:playerEnvoy.intramuralID])
        {
            returnValue = YES;
            break;
        }
    }
    if (!self.contributeurIDs)
    {
        [self loadContributeurIDs];
    }
    if (!returnValue)
    {
        for (NSString *intramuralID in self.contributeurIDs)
        {
            if ([intramuralID isEqualToString:playerEnvoy.intramuralID])
            {
                returnValue = YES;
                break;
            }
        }
    }
    return returnValue;
}


#pragma mark - Saboteurs and Contributeurs

- (void)applySaboteur:(PlayerEnvoy *)saboteur
{
    if (!self.saboteurIDs)
    {
        self.saboteurIDs = [NSArray arrayWithObject:saboteur.intramuralID];
    }
    else
    {
        for (NSString *saboteurID in self.saboteurIDs)
        {
            if ([saboteurID isEqualToString:saboteur.intramuralID])
            {
                return;
            }
        }
        self.saboteurIDs = [self.saboteurIDs arrayByAddingObject:saboteur.intramuralID];
    }
}

- (NSArray *)saboteurs
{
    if (!self.saboteurIDs)
    {
        [self loadSaboteurIDs];
    }
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.saboteurIDs.count];
    for (NSString *intramuralID in self.saboteurIDs)
    {
        [list addObject:[PlayerEnvoy envoyFromIntramuralID:intramuralID]];
    }
    NSArray *returnValue = [NSArray arrayWithArray:list];
    [list release];
    return returnValue;
}

- (void)loadSaboteurIDs
{
    if (!self.managedObjectID)
    {
        return;
    }
    NSManagedObjectContext *context = [JSKDataMiner sharedInstance].mainObjectContext;
    Mission *mission = (Mission *)[context objectWithID:self.managedObjectID];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:mission.saboteurs.count];
    for (GamePlayer *gamePlayer in mission.saboteurs)
    {
        [list addObject:gamePlayer.player.intramuralID];
    }
    self.saboteurIDs = [NSArray arrayWithArray:list];
    [list release];
}


- (void)applyContributeur:(PlayerEnvoy *)contributeur
{
    if (!self.contributeurIDs)
    {
        self.contributeurIDs = [NSArray arrayWithObject:contributeur.intramuralID];
    }
    else
    {
        for (NSString *contributeurID in self.contributeurIDs)
        {
            if ([contributeurID isEqualToString:contributeur.intramuralID])
            {
                return;
            }
        }
        self.contributeurIDs = [self.contributeurIDs arrayByAddingObject:contributeur.intramuralID];
    }
}

- (NSArray *)contributeurs
{
    if (!self.contributeurIDs)
    {
        [self loadContributeurIDs];
    }
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.contributeurIDs.count];
    for (NSString *intramuralID in self.contributeurIDs)
    {
        [list addObject:[PlayerEnvoy envoyFromIntramuralID:intramuralID]];
    }
    NSArray *returnValue = [NSArray arrayWithArray:list];
    [list release];
    return returnValue;
}

- (void)loadContributeurIDs
{
    if (!self.managedObjectID)
    {
        return;
    }
    NSManagedObjectContext *context = [JSKDataMiner sharedInstance].mainObjectContext;
    Mission *mission = (Mission *)[context objectWithID:self.managedObjectID];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:mission.contributeurs.count];
    for (GamePlayer *gamePlayer in mission.contributeurs)
    {
        [list addObject:gamePlayer.player.intramuralID];
    }
    self.contributeurIDs = [NSArray arrayWithArray:list];
    [list release];
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
    if (self.saboteurIDs.count + self.contributeurIDs.count == self.teamCount)
    {
        self.isComplete = YES;
        if (self.saboteurIDs.count == 0)
        {
            self.didSucceed = YES;
        }
    }
    
    
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
    
    model.hasStarted = [NSNumber numberWithBool:self.hasStarted];
    model.didSucceed = [NSNumber numberWithBool:self.didSucceed];
    model.isComplete = [NSNumber numberWithBool:self.isComplete];
    model.missionName = self.missionName;
    model.missionNumber = [NSNumber numberWithUnsignedInteger:self.missionNumber];
    model.teamCount = [NSNumber numberWithUnsignedInteger:self.teamCount];
    
    
    
    // Coordinator.
    if (self.coordinatorID)
    {
        GamePlayer *gamePlayer = [[context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"player.intramuralID == %@", self.coordinatorID] objectAtIndex:0];
        model.coordinator = gamePlayer;
    }
    
    
    // Team members.
    if (self.teamMemberIDs.count == 0)
    {
        [model removeTeamMembers:model.teamMembers];
    }
    else
    {
        for (NSString *intramuralID in self.teamMemberIDs)
        {
            NSArray *gamePlayers = [context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"player.intramuralID == %@", intramuralID];
            if (gamePlayers.count > 0)
            {
                GamePlayer *gamePlayer = [gamePlayers objectAtIndex:0];
                [model addTeamMembersObject:gamePlayer];
            }
        }
    }
    
    
    // Saboteurs.
    for (NSString *intramuralID in self.saboteurIDs)
    {
        GamePlayer *gamePlayer = [[context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"player.intramuralID == %@", intramuralID] objectAtIndex:0];
        [model addSaboteursObject:gamePlayer];
    }
    
    
    // Contributeurs.
    for (NSString *intramuralID in self.contributeurIDs)
    {
        GamePlayer *gamePlayer = [[context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"player.intramuralID == %@", intramuralID] objectAtIndex:0];
        [model addContributeursObject:gamePlayer];
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
    
    [aCoder encodeBool:self.hasStarted forKey:@"hasStarted"];
    [aCoder encodeBool:self.didSucceed forKey:@"didSucceed"];
    [aCoder encodeBool:self.isComplete forKey:@"isComplete"];
    [aCoder encodeObject:self.missionName forKey:@"missionName"];
    [aCoder encodeInteger:self.missionNumber forKey:@"missionNumber"];
    [aCoder encodeInteger:self.teamCount forKey:@"teamCount"];
    [aCoder encodeObject:self.gameID forKey:@"gameID"];
    [aCoder encodeObject:self.coordinatorID forKey:@"coordinatorID"];
    [aCoder encodeObject:self.teamMemberIDs forKey:@"teamMemberIDs"];
    [aCoder encodeObject:self.saboteurIDs forKey:@"saboteurIDs"];
    [aCoder encodeObject:self.contributeurIDs forKey:@"contributeurIDs"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.hasStarted = [aDecoder decodeBoolForKey:@"hasStarted"];
        self.didSucceed = [aDecoder decodeBoolForKey:@"didSucceed"];
        self.isComplete = [aDecoder decodeBoolForKey:@"isComplete"];
        self.missionName = [aDecoder decodeObjectForKey:@"missionName"];
        self.missionNumber = [aDecoder decodeIntegerForKey:@"missionNumber"];
        self.teamCount = [aDecoder decodeIntegerForKey:@"teamCount"];
        self.gameID = [aDecoder decodeObjectForKey:@"gameID"];
        self.coordinatorID = [aDecoder decodeObjectForKey:@"coordinatorID"];
        self.teamMemberIDs = [aDecoder decodeObjectForKey:@"teamMemberIDs"];
        self.saboteurIDs = [aDecoder decodeObjectForKey:@"saboteurIDs"];
        self.contributeurIDs = [aDecoder decodeObjectForKey:@"contributeurIDs"];
        
        if (self.coordinatorID)
        {
            self.coordinator = [PlayerEnvoy envoyFromIntramuralID:self.coordinatorID];
        }
    }
    
    return self;
}


@end
