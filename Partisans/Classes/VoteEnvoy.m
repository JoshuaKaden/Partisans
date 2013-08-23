//
//  VoteEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//
//  Copyright (c) 2013, Joshua Kaden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
        self.intramuralID    = managedObject.intramuralID;
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        }
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
    
    
    // Ensure that this player hasn't already voted.
    BOOL hasAlreadyVoted = NO;
    NSArray *rounds = [context fetchObjectArrayForEntityName:@"Round" withPredicateFormat:@"intramuralID == %@", self.roundID];
    Round *round = [rounds objectAtIndex:0];
    for (Vote *vote in round.votes)
    {
        if ([vote.gamePlayer.player.intramuralID isEqualToString:self.playerID])
        {
            hasAlreadyVoted = YES;
            break;
        }
    }
    if (hasAlreadyVoted)
    {
//        debugLog(@"Player has already voted: %@", self);
        return;
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
