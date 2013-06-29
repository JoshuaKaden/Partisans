//
//  VoteEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "VoteEnvoy.h"

#import "Game.h"
#import "GamePlayer.h"
#import "JSKDataMiner.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "Round.h"
#import "SystemMessage.h"
#import "Vote.h"


@implementation VoteEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize isCast = m_isCast;
@synthesize isYea = m_isYea;
@synthesize roundID = m_roundID;
@synthesize playerID = m_playerID;


- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_roundID release];
    [m_playerID release];
    
    [super dealloc];
}


#pragma mark - Envoy

- (id)initWithManagedObject:(Vote *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID    = [[self.managedObjectID URIRepresentation] absoluteString];
        self.isCast          = [managedObject.isCast boolValue];
        self.isYea           = [managedObject.isYea boolValue];
        self.roundID         = managedObject.round.intramuralID;
        self.playerID        = managedObject.gamePlayer.player.intramuralID;
    }
    return self;
}


+ (VoteEnvoy *)envoyFromManagedObject:(Vote *)managedObject
{
    VoteEnvoy *envoy = [[[VoteEnvoy alloc] initWithManagedObject:managedObject] autorelease];
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
    
    NSString *roundIDString = self.roundID;
    if (!roundIDString)
    {
        roundIDString = @"";
    }
    
    NSString *playerIDString = self.playerID;
    if (!playerIDString)
    {
        playerIDString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"VoteEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              managedObjectString, @"managedObjectID",
                              [NSNumber numberWithBool:self.isCast].description, @"isCast",
                              [NSNumber numberWithBool:self.isYea].description, @"isYea",
                              roundIDString, @"roundID",
                              playerIDString, @"playerID", nil];
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
    
    Vote *model = nil;
    if (self.managedObjectID)
    {
        model = (Vote *)[context objectWithID:self.managedObjectID];
    }
    
    // This could be an update from the host in which case we have to hook up to the correct via the intramural ID.
    if (!model)
    {
        if (self.intramuralID)
        {
            NSArray *list = [context fetchObjectArrayForEntityName:@"Vote" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (list.count > 0)
            {
                model = [list objectAtIndex:0];
                self.managedObjectID = model.objectID;
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Vote" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.isCast = [NSNumber numberWithBool:self.isCast];
    model.isYea = [NSNumber numberWithBool:self.isYea];
    
    
    // The round.
    if (!model.round)
    {
        NSArray *list = [context fetchObjectArrayForEntityName:@"Round" withPredicateFormat:@"intramuralID == %@", self.roundID];
        model.round = [list objectAtIndex:0];
    }
    
    
    // The game player.
    if (!model.gamePlayer)
    {
        Game *game = model.round.game;
        for (GamePlayer *gamePlayer in game.gamePlayers)
        {
            if ([gamePlayer.player.intramuralID isEqualToString:self.playerID])
            {
                model.gamePlayer = gamePlayer;
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
    
    [aCoder encodeBool:self.isCast forKey:@"isCast"];
    [aCoder encodeBool:self.isYea forKey:@"isYea"];
    [aCoder encodeObject:self.roundID forKey:@"roundID"];
    [aCoder encodeObject:self.playerID forKey:@"playerID"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.isCast = [aDecoder decodeBoolForKey:@"isCast"];
        self.isYea = [aDecoder decodeBoolForKey:@"isYea"];
        self.roundID = [aDecoder decodeObjectForKey:@"roundID"];
        self.playerID = [aDecoder decodeObjectForKey:@"playerID"];
    }
    
    return self;
}


@end
