//
//  GameEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
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

#import "GameEnvoy.h"

#import "Game.h"
#import "GamePlayer.h"
#import "GamePlayerEnvoy.h"
#import "JSKDataMiner.h"
#import "Mission.h"
#import "MissionEnvoy.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "PlayerEnvoy.h"
#import "Round.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"


@interface GameEnvoy ()
@property (nonatomic, strong) NSArray *gamePlayerEnvoys;
@property (nonatomic, strong) NSArray *deletedGamePlayerEnvoys;
@property (nonatomic, strong) NSArray *missionEnvoys;
@property (nonatomic, strong) NSArray *roundEnvoys;
- (void)loadGamePlayerEnvoys;
- (void)loadMissionEnvoys;
- (void)loadRoundEnvoys;
@end


@implementation GameEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize importedObjectString = m_importedObjectString;

@synthesize startDate = m_startDate;
@synthesize endDate = m_endDate;
@synthesize numberOfPlayers = m_numberOfPlayers;
@synthesize gamePlayerEnvoys = m_gamePlayerEnvoys;
@synthesize modifiedDate = m_modifiedDate;
@synthesize deletedGamePlayerEnvoys = m_deletedGamePlayerEnvoys;
@synthesize missionEnvoys = m_missionEnvoys;
@synthesize roundEnvoys = m_roundEnvoys;
@synthesize gameCode = m_gameCode;
@synthesize hasScoreBeenShown = m_hasScoreBeenShown;




- (id)initWithManagedObject:(Game *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID = managedObject.intramuralID;
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        }
        self.startDate = managedObject.startDate;
        self.endDate = managedObject.endDate;
        self.numberOfPlayers = [managedObject.numberOfPlayers unsignedIntegerValue];
        self.modifiedDate = managedObject.modifiedDate;
        self.gameCode = [managedObject.gameCode unsignedIntegerValue];
        
        [self loadGamePlayerEnvoys];
        [self loadMissionEnvoys];
        [self loadRoundEnvoys];
    }
    
    return self;
}


+ (GameEnvoy *)envoyFromManagedObject:(Game *)managedObject
{
    GameEnvoy *envoy = [[GameEnvoy alloc] initWithManagedObject:managedObject];
    return envoy;
}



- (NSString *)description
{
    NSString *importedObjectString = self.importedObjectString;
    if (!importedObjectString)
    {
        importedObjectString = @"";
    }
    
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
    
    NSString *startDateString = [self.startDate description];
    if (!startDateString)
    {
        startDateString = @"";
    }
    
    NSString *endDateString = [self.endDate description];
    if (!endDateString)
    {
        endDateString = @"";
    }
    
    NSString *gamePlayerEnvoysString = [self.gamePlayerEnvoys description];
    if (!gamePlayerEnvoysString)
    {
        gamePlayerEnvoysString = @"";
    }
    
    NSString *modifiedDateString = self.modifiedDate.description;
    if (!modifiedDateString)
    {
        modifiedDateString = @"";
    }
    
    NSString *missionEnvoysString = [self.missionEnvoys description];
    if (!missionEnvoysString)
    {
        missionEnvoysString = @"";
    }
    
    NSString *roundEnvoysString = [self.roundEnvoys description];
    if (!roundEnvoysString)
    {
        roundEnvoysString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"GameEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              importedObjectString, @"importedObjectString",
                              managedObjectString, @"managedObjectID",
                              startDateString, @"startDate",
                              endDateString, @"endDate",
                              [NSNumber numberWithUnsignedInteger:self.numberOfPlayers].description, @"numberOfPlayers",
                              gamePlayerEnvoysString, @"gamePlayerEnvoys",
                              modifiedDateString, @"modifiedDate",
                              missionEnvoysString, @"missionEnvoys",
                              roundEnvoysString, @"roundEnvoys",
                              [NSNumber numberWithUnsignedInteger:self.operativeCount], @"operativeCount",
                              [NSNumber numberWithUnsignedInteger:self.gameCode], @"gameCode", nil];
    return descDict.description;
}



+ (GameEnvoy *)envoyFromIntramuralID:(NSString *)intramuralID
{
    GameEnvoy *returnValue = nil;
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSArray *games = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", intramuralID];
    if (games.count > 0)
    {
        Game *game = [games objectAtIndex:0];
        returnValue = [self envoyFromManagedObject:game];
    }
    return returnValue;
}


+ (GameEnvoy *)envoyFromHost:(PlayerEnvoy *)host
{
    if (!host.managedObjectID)
    {
        return nil;
    }
    
    GameEnvoy *returnValue = nil;
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Player *player = (Player *)[context objectWithID:host.managedObjectID];
    if (player.gamePlayer)
    {
        if ([player.gamePlayer.isHost boolValue])
        {
            Game *game = player.gamePlayer.game;
            returnValue = [GameEnvoy envoyFromManagedObject:game];
        }
    }
    
    return returnValue;
}

+ (GameEnvoy *)envoyFromPlayer:(PlayerEnvoy *)playerEnvoy
{
    if (!playerEnvoy.managedObjectID)
    {
        return nil;
    }
    
    GameEnvoy *returnValue = nil;
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Player *player = (Player *)[context objectWithID:playerEnvoy.managedObjectID];
    if (player.gamePlayer)
    {
        if (![player.gamePlayer.isHost boolValue])
        {
            Game *game = player.gamePlayer.game;
            returnValue = [GameEnvoy envoyFromManagedObject:game];
        }
    }
    
    return returnValue;
}



//+ (GameEnvoy *)createGame
//{
//    return nil;
//    // This needs to be in an operation, I think.
//    // Which means a notification key "gameWasCreated", for the caller to observe.
//    // Since we won't be returning a GameEnvoy, since this is now an asynchornous operation.
//    
//    
//    
//    // Create the game itself.
//    GameEnvoy *newGameEnvoy = [[[GameEnvoy alloc] init] autorelease];
//    newGameEnvoy.numberOfPlayers = kPartisansMinPlayers;
//    [newGameEnvoy commitAndSave];
//
//    [newGameEnvoy addHost:[SystemMessage playerEnvoy]];
//    
//    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
//    Game *newGame = (Game *)[context objectWithID:newGameEnvoy.managedObjectID];
//    
////    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
////    Game *newGame = (Game *)[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
////    newGame.numberOfPlayers = [NSNumber numberWithInt:5];
////    
////    // Add the host.
////    PlayerEnvoy *hostEnvoy = [SystemMessage playerEnvoy];
////    Player *host = (Player *)[context objectWithID:hostEnvoy.managedObjectID];
////    GamePlayer *gamePlayer = (GamePlayer *)[NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
////    gamePlayer.player = host;
////    gamePlayer.isHost = [NSNumber numberWithBool:YES];
////    [newGame addGamePlayersObject:gamePlayer];
//    
//    // Add the missions.
//    for (NSUInteger missionIndex = 0; missionIndex < 5; missionIndex++)
//    {
//        Mission *mission = (Mission *)[NSEntityDescription insertNewObjectForEntityForName:@"Mission" inManagedObjectContext:context];
//        mission.missionNumber = [NSNumber numberWithUnsignedInteger:missionIndex + 1];
//        [newGame addMissionsObject:mission];
//    }
//    
//    [JSKDataMiner save];
//    
//    GameEnvoy *returnValue = [GameEnvoy envoyFromManagedObject:newGame];
//    return returnValue;
//}


- (void)loadGamePlayerEnvoys
{
    if (!self.managedObjectID)
    {
        return;
    }
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    if (game.gamePlayers.count == 0)
    {
        // This could be a place to catch a badly saved game.
        return;
    }
    
    
//    // Bad record cleanup.
//    NSSet *orphans = [game.gamePlayers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"player == nil"]];
//    for (GamePlayer *orphan in orphans)
//    {
//        [context deleteObject:orphan];
//        [context save:nil];
//    }
    
    
    
    NSSet *playerSet = game.gamePlayers;
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"player.playerName" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:nameSort, nil];
    NSArray *gamePlayers = [playerSet sortedArrayUsingDescriptors:sorts];
    
    NSMutableArray *envoyList = [[NSMutableArray alloc] initWithCapacity:gamePlayers.count];
    for (GamePlayer *gamePlayer in gamePlayers)
    {
        GamePlayerEnvoy *envoy = [[GamePlayerEnvoy alloc] initWithManagedObject:gamePlayer];
        [envoyList addObject:envoy];
    }
    
    [self setGamePlayerEnvoys:[NSArray arrayWithArray:envoyList]];
}


- (void)loadMissionEnvoys
{
    if (!self.managedObjectID)
    {
        return;
    }
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    
    NSSet *missionSet = game.missions;
    NSSortDescriptor *numberSort = [[NSSortDescriptor alloc] initWithKey:@"missionNumber" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:numberSort, nil];
    NSArray *missions = [missionSet sortedArrayUsingDescriptors:sorts];
    
    NSMutableArray *envoyList = [[NSMutableArray alloc] initWithCapacity:missions.count];
    for (Mission *mission in missions)
    {
        MissionEnvoy *envoy = [[MissionEnvoy alloc] initWithManagedObject:mission];
        [envoyList addObject:envoy];
    }
    
    [self setMissionEnvoys:[NSArray arrayWithArray:envoyList]];
}


- (void)loadRoundEnvoys
{
    if (!self.managedObjectID)
    {
        return;
    }
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    
    NSSet *roundSet = game.rounds;
    NSSortDescriptor *numberSort = [[NSSortDescriptor alloc] initWithKey:@"roundNumber" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:numberSort, nil];
    NSArray *rounds = [roundSet sortedArrayUsingDescriptors:sorts];
    
    NSMutableArray *envoyList = [[NSMutableArray alloc] initWithCapacity:rounds.count];
    for (Round *round in rounds)
    {
        RoundEnvoy *envoy = [[RoundEnvoy alloc] initWithManagedObject:round];
        [envoyList addObject:envoy];
    }
    
    [self setRoundEnvoys:[NSArray arrayWithArray:envoyList]];
}


- (NSArray *)players
{
    if (!self.managedObjectID)
    {
        return nil;
    }
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    NSSet *playerSet = game.gamePlayers;
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"player.playerName" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:nameSort, nil];
    NSArray *players = [playerSet sortedArrayUsingDescriptors:sorts];
    
    NSMutableArray *envoys = [[NSMutableArray alloc] initWithCapacity:players.count];
    for (GamePlayer *gamePlayer in players)
    {
        PlayerEnvoy *envoy = [[PlayerEnvoy alloc] initWithManagedObject:gamePlayer.player];
        [envoys addObject:envoy];
    }
    
    NSArray *returnValue = [NSArray arrayWithArray:envoys];
    
    return returnValue;
}

- (NSArray *)operatives
{
    if (!self.managedObjectID)
    {
        return nil;
    }
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    NSSet *playerSet = game.gamePlayers;
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"player.playerName" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:nameSort, nil];
    NSArray *players = [playerSet sortedArrayUsingDescriptors:sorts];
    
    NSMutableArray *envoys = [[NSMutableArray alloc] initWithCapacity:players.count];
    for (GamePlayer *gamePlayer in players)
    {
        if ([gamePlayer.isOperative boolValue])
        {
            PlayerEnvoy *envoy = [[PlayerEnvoy alloc] initWithManagedObject:gamePlayer.player];
            [envoys addObject:envoy];
        }
    }
    
    NSArray *returnValue = [NSArray arrayWithArray:envoys];
    
    return returnValue;
}

- (PlayerEnvoy *)host
{
    if (!self.managedObjectID)
    {
        return nil;
    }
    
    PlayerEnvoy *returnValue = nil;
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    for (GamePlayer *gamePlayer in game.gamePlayers)
    {
        if ([gamePlayer.isHost boolValue])
        {
            returnValue = [PlayerEnvoy envoyFromManagedObject:gamePlayer.player];
            break;
        }
    }
    
    return returnValue;
}

- (void)addHost:(PlayerEnvoy *)playerEnvoy
{
    if ([self isPlayerInGame:playerEnvoy])
    {
        return;
    }
    if (!self.gamePlayerEnvoys)
    {
        self.gamePlayerEnvoys = [NSArray array];
    }
    GamePlayerEnvoy *gamePlayerEnvoy = [[GamePlayerEnvoy alloc] init];
    gamePlayerEnvoy.playerID = playerEnvoy.intramuralID;
    gamePlayerEnvoy.gameID = self.intramuralID;
    gamePlayerEnvoy.isHost = YES;
    NSArray *gamePlayerEnvoys = [self.gamePlayerEnvoys arrayByAddingObject:gamePlayerEnvoy];
    [self setGamePlayerEnvoys:gamePlayerEnvoys];
    self.numberOfPlayers = self.gamePlayerEnvoys.count;
//    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
//    Player *player = (Player *)[context objectWithID:playerEnvoy.managedObjectID];
//    GamePlayer *gamePlayer = (GamePlayer *)[NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
//    gamePlayer.player = player;
//    gamePlayer.isHost = [NSNumber numberWithBool:YES];
//    Game *game = (Game *)[context objectWithID:self.managedObjectID];
//    [game addGamePlayersObject:gamePlayer];
}


- (void)addPlayer:(PlayerEnvoy *)playerEnvoy
{
    if ([self isPlayerInGame:playerEnvoy])
    {
        return;
    }
    if (!self.gamePlayerEnvoys)
    {
        self.gamePlayerEnvoys = [NSArray array];
    }
    
    BOOL matchFound = NO;
    for (PlayerEnvoy *existingPlayer in self.gamePlayerEnvoys)
    {
        if ([existingPlayer.intramuralID isEqualToString:playerEnvoy.intramuralID])
        {
            matchFound = YES;
            break;
        }
    }
    if (matchFound)
    {
        return;
    }
    
    GamePlayerEnvoy *gamePlayerEnvoy = [[GamePlayerEnvoy alloc] init];
    gamePlayerEnvoy.playerID = playerEnvoy.intramuralID;
    gamePlayerEnvoy.gameID = self.intramuralID;
    gamePlayerEnvoy.isHost = NO;
    NSArray *gamePlayerEnvoys = [self.gamePlayerEnvoys arrayByAddingObject:gamePlayerEnvoy];
    [self setGamePlayerEnvoys:gamePlayerEnvoys];
    self.numberOfPlayers = self.gamePlayerEnvoys.count;
//    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
//    Player *player = (Player *)[context objectWithID:playerEnvoy.managedObjectID];
//    GamePlayer *gamePlayer = (GamePlayer *)[NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
//    gamePlayer.player = player;
//    gamePlayer.isHost = [NSNumber numberWithBool:NO];
//    Game *game = (Game *)[context objectWithID:self.managedObjectID];
//    [game addGamePlayersObject:gamePlayer];
}

- (BOOL)isPlayerInGame:(PlayerEnvoy *)playerEnvoy
{
    BOOL returnValue = NO;
    for (GamePlayerEnvoy *gamePlayerEnvoy in self.gamePlayerEnvoys)
    {
        if ([gamePlayerEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
        {
            returnValue = YES;
            break;
        }
    }
    return returnValue;
//    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
//    Game *game = (Game *)[context objectWithID:self.managedObjectID];
//    for (GamePlayer *gamePlayer in game.gamePlayers)
//    {
//        if ([gamePlayer.player.intramuralID isEqualToString:playerEnvoy.intramuralID])
//        {
//            return YES;
//        }
//    }
//    return NO;
}

- (BOOL)isPlayerAnOperative:(PlayerEnvoy *)playerEnvoy
{
    if (!playerEnvoy)
    {
        playerEnvoy = [SystemMessage playerEnvoy];
    }
    BOOL returnValue = NO;
    for (GamePlayerEnvoy *gamePlayerEnvoy in self.gamePlayerEnvoys)
    {
        if ([gamePlayerEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
        {
            returnValue = gamePlayerEnvoy.isOperative;
            break;
        }
    }
    return returnValue;
}

- (void)removePlayer:(PlayerEnvoy *)playerEnvoy
{
    GamePlayerEnvoy *theGamePlayerEnvoyThatWillBeRemoved = nil;
    for (GamePlayerEnvoy *gamePlayerEnvoy in self.gamePlayerEnvoys)
    {
        if ([gamePlayerEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
        {
            // But not if we're removing the host!
            // Can't do that.
            if (gamePlayerEnvoy.isHost)
            {
                return;
            }
            theGamePlayerEnvoyThatWillBeRemoved = gamePlayerEnvoy;
            break;
        }
    }
    
    if (!theGamePlayerEnvoyThatWillBeRemoved)
    {
        return;
    }
    
    
    if (self.deletedGamePlayerEnvoys)
    {
        NSMutableArray *deleted = [[NSMutableArray alloc] initWithArray:self.deletedGamePlayerEnvoys];
        [deleted addObject:theGamePlayerEnvoyThatWillBeRemoved];
        self.deletedGamePlayerEnvoys = [NSArray arrayWithArray:deleted];
    }
    else
    {
        self.deletedGamePlayerEnvoys = [NSArray arrayWithObject:theGamePlayerEnvoyThatWillBeRemoved];
    }

    
    NSMutableArray *gamePlayerEnvoyList = [[NSMutableArray alloc] initWithArray:self.gamePlayerEnvoys];
    [gamePlayerEnvoyList removeObject:theGamePlayerEnvoyThatWillBeRemoved];
    self.gamePlayerEnvoys = [NSArray arrayWithArray:gamePlayerEnvoyList];
    self.numberOfPlayers = self.gamePlayerEnvoys.count;
    
    
//    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
//    Player *player = (Player *)[context objectWithID:playerEnvoy.managedObjectID];
//    NSArray *gamePlayers = [context fetchObjectArrayForEntityName:@"gamePlayer" withPredicateFormat:@"player == %@", player];
//    if (!gamePlayers)
//    {
//        return;
//    }
//    GamePlayer *gamePlayer = [gamePlayers objectAtIndex:0];
//    [context deleteObject:gamePlayer];
}


- (void)addMission:(MissionEnvoy *)missionEnvoy
{
    if (!self.missionEnvoys)
    {
        self.missionEnvoys = [NSArray array];
    }
    NSArray *missionEnvoys= [self.missionEnvoys arrayByAddingObject:missionEnvoy];
    [self setMissionEnvoys:missionEnvoys];
}

- (GamePlayerEnvoy *)gamePlayerEnvoyFromPlayer:(PlayerEnvoy *)playerEnvoy
{
    GamePlayerEnvoy *returnValue = nil;
    for (GamePlayerEnvoy *gamePlayerEnvoy in self.gamePlayerEnvoys)
    {
        if ([gamePlayerEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
        {
            returnValue = gamePlayerEnvoy;
            break;
        }
    }
    return returnValue;
}

- (NSUInteger)operativeCount
{
    NSArray *operatives = [self.gamePlayerEnvoys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isOperative == YES"]];
    return operatives.count;
}

- (NSUInteger)roundCount
{
    return self.roundEnvoys.count;
}

- (RoundEnvoy *)roundEnvoyFromNumber:(NSUInteger)roundNumber
{
    RoundEnvoy *returnValue = nil;
    for (RoundEnvoy *envoy in self.roundEnvoys)
    {
        if (envoy.roundNumber == roundNumber)
        {
            returnValue = envoy;
            break;
        }
    }
    return returnValue;
}

- (RoundEnvoy *)currentRound
{
    return [self.roundEnvoys lastObject];
}

- (void)addRound:(RoundEnvoy *)roundEnvoy
{
    if (!self.roundEnvoys)
    {
        self.roundEnvoys = [NSArray arrayWithObject:roundEnvoy];
        return;
    }
    NSArray *rounds = [self.roundEnvoys arrayByAddingObject:roundEnvoy];
    self.roundEnvoys = rounds;
}

- (MissionEnvoy *)missionEnvoyFromNumber:(NSUInteger)missionNumber
{
    MissionEnvoy *returnValue = nil;
    for (MissionEnvoy *missionEnvoy in self.missionEnvoys)
    {
        if (missionEnvoy.missionNumber == missionNumber)
        {
            returnValue = missionEnvoy;
            break;
        }
    }
    return returnValue;
}


- (MissionEnvoy *)currentMission
{
    MissionEnvoy *returnValue = nil;
    RoundEnvoy *currentRound = [self currentRound];
    if (currentRound)
    {
        returnValue = [self missionEnvoyFromNumber:currentRound.missionNumber];
    }
    return returnValue;
}

- (MissionEnvoy *)firstIncompleteMission
{
    MissionEnvoy *returnValue = nil;
    NSArray *completed = [self.missionEnvoys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isComplete == YES"]];
    if (completed.count == 0)
    {
        returnValue = [self missionEnvoyFromNumber:1];
    }
    else
    {
        MissionEnvoy *previous = [completed lastObject];
        returnValue = [self missionEnvoyFromNumber:previous.missionNumber + 1];
    }
    return returnValue;
}

- (NSUInteger)successfulMissionCount
{
    NSUInteger successCount = 0;
    for (MissionEnvoy *missionEnvoy in self.missionEnvoys)
    {
        if (missionEnvoy.isComplete)
        {
            if (missionEnvoy.didSucceed)
            {
                successCount ++;
            }
        }
    }
    return successCount;
}

- (NSUInteger)failedMissionCount
{
    NSUInteger failCount = 0;
    for (MissionEnvoy *missionEnvoy in self.missionEnvoys)
    {
        if (missionEnvoy.isComplete)
        {
            if (!missionEnvoy.didSucceed)
            {
                failCount ++;
            }
        }
    }
    return failCount;
}


#pragma mark - Commits

- (void)commitModifiedDate
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    if (!self.managedObjectID)
    {
        // Bail in this case.
        // Should not happen however.
        return;
    }
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    if (!game)
    {
        // Something badly wrong in this case.
        debugLog(@"Problem!!");
        return;
    }
    
    game.modifiedDate = self.modifiedDate;
}

- (void)deleteGame
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    if (!self.managedObjectID)
    {
        // Bail in this case.
        // Should not happen however.
        return;
    }
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    if (!game)
    {
        // Something badly wrong in this case.
        debugLog(@"Problem!!");
        return;
    }
    
    // Delete the gameplayers manually.
    // Cudgel to remedy orphaned gameplayer rows.
    NSSet *gamePlayers = game.gamePlayers;
    for (GamePlayer *gamePlayer in gamePlayers)
    {
        gamePlayer.player = nil;
        [context deleteObject:gamePlayer];
    }
    
    
    [context deleteObject:game];
    [self setManagedObjectID:nil];
    [self setIntramuralID:nil];
    [JSKDataMiner save];
}


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
    
    Game *model = nil;
    if (self.managedObjectID)
    {
        model = (Game *)[context objectWithID:self.managedObjectID];
    }
    
    // We actually may already know about the game, and are receiving an update from the host.
    BOOL isUpdateFromHost = NO;
    if (!model)
    {
        if (self.intramuralID)
        {
            NSArray *games = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (games.count > 0)
            {
                model = [games objectAtIndex:0];
                self.managedObjectID = model.objectID;
                isUpdateFromHost = YES;
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
    }
    
    
    if (model.modifiedDate && self.modifiedDate)
    {
        NSDate *oldDate = model.modifiedDate;
        NSDate *newDate = self.modifiedDate;
        NSInteger seconds = [SystemMessage secondsBetweenDates:oldDate toDate:newDate];
        if (seconds == 0)
        {
            self.modifiedDate = [NSDate date];
        }
    }
    
    if (!self.modifiedDate)
    {
        self.modifiedDate = [NSDate date];
    }
    
    
    model.intramuralID = self.intramuralID; 
    
    model.startDate = self.startDate;
    model.endDate = self.endDate;
    model.numberOfPlayers = [NSNumber numberWithUnsignedInteger:self.numberOfPlayers];
    model.modifiedDate = self.modifiedDate;
    model.gameCode = [NSNumber numberWithUnsignedInteger:self.gameCode];
    
    if (self.gamePlayerEnvoys)
    {
        for (GamePlayerEnvoy *envoy in self.gamePlayerEnvoys)
        {
            Player *player = nil;
            GamePlayer *gamePlayer = nil;
            if (envoy.managedObjectID)
            {
                gamePlayer = (GamePlayer *)[context objectWithID:envoy.managedObjectID];
            }
            
            // This could be an update from the host in which case we have to hook up to the correct row via the intramural ID.
            if (!gamePlayer)
            {
                if (envoy.intramuralID)
                {
                    NSArray *gamePlayers = [context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"intramuralID == %@", envoy.intramuralID];
                    if (gamePlayers.count > 0)
                    {
                        gamePlayer = [gamePlayers objectAtIndex:0];
                        envoy.managedObjectID = gamePlayer.objectID;
                    }
                }
            }
            
//            if (!gamePlayer)
//            {
                if (envoy.playerID)
                {
                    // Let's make sure we have a matching Player record.
                    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"intramuralID == %@", envoy.playerID];
                    if (players.count == 0)
                    {
                        // Oops, we don't have this Player's data yet.
                        // So, let's stub one in.
                        player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                        player.intramuralID = envoy.playerID;
                        player.isDefault = NO;
                        player.isNative = NO;
                        player.playerName = NSLocalizedString(@"TBA", @"TBA  --  label");
                        player.modifiedDate = [NSDate distantPast];
                    }
                    else
                    {
                        player = [players objectAtIndex:0];
                    }
//                    else
//                    {
//                        NSArray *gamePlayers = [context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"player.intramuralID == %@", envoy.playerID];
//                        if (gamePlayers.count > 0)
//                        {
//                            gamePlayer = [gamePlayers objectAtIndex:0];
//                            envoy.managedObjectID = gamePlayer.objectID;
//                        }
//                    }
                }
//            }

            
            if (!gamePlayer)
            {
                // This will create the GamePlayer row.
                gamePlayer = [NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
                if (player)
                {
                    gamePlayer.player = player;
                }
                // This will associate the new row with the envoy, via the NSManagedObjectID.
                NSError *error = nil;
                [context obtainPermanentIDsForObjects:[NSArray arrayWithObject:gamePlayer] error:&error];
                if (!error)
                {
                    envoy.managedObjectID = gamePlayer.objectID;
                }
            }
            
            [envoy commitInContext:context];
            [model addGamePlayersObject:gamePlayer];
        }
    }
    
    
    // This is Host code, for handling players who have left the game.
    if (self.deletedGamePlayerEnvoys)
    {
        for (PlayerEnvoy *deletedEnvoy in self.deletedGamePlayerEnvoys)
        {
            if (!deletedEnvoy.managedObjectID)
            {
                NSArray *deletedPlayers = [context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"intramuralID == %@", deletedEnvoy.intramuralID];
                GamePlayer *deletedPlayer = [deletedPlayers objectAtIndex:0];
                [context deleteObject:deletedPlayer];
            }
            else
            {
                GamePlayer *deletedPlayer = (GamePlayer *)[context objectWithID:deletedEnvoy.managedObjectID];
                [context deleteObject:deletedPlayer];
            }
        }
        self.deletedGamePlayerEnvoys = nil;
    }
    
    
    // This is the Player code for handling players who have left the game.
    if (isUpdateFromHost)
    {
        if (self.gamePlayerEnvoys.count != model.gamePlayers.count)
        {
            NSMutableArray *hitList = [[NSMutableArray alloc] initWithCapacity:model.gamePlayers.count];
            // Let's find the player who has left (or the players who have left).
            for (GamePlayer *gamePlayer in model.gamePlayers)
            {
                NSString *playerID = gamePlayer.player.intramuralID;
                NSArray *envoyList = [self.gamePlayerEnvoys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"playerID == %@", playerID]];
                if (envoyList.count == 0)
                {
                    // Bingo: We found a locally-saved game player who isn't in the game envoy.
                    // So, let's arrange to have it neutralized.
                    [hitList addObject:gamePlayer];
                }
            }
            for (GamePlayer *target in hitList)
            {
                [context deleteObject:target];
            }
        }
    }
    
    
    
    // The Missions.
    for (MissionEnvoy *envoy in self.missionEnvoys)
    {
        Mission *mission = nil;
        if (envoy.managedObjectID)
        {
            mission = (Mission *)[context objectWithID:envoy.managedObjectID];
        }
        
        // This could be an update from the host in which case we have to hook up to the correct via the intramural ID.
        if (!mission)
        {
            if (envoy.intramuralID)
            {
                NSArray *missionList = [context fetchObjectArrayForEntityName:@"Mission" withPredicateFormat:@"intramuralID == %@", envoy.intramuralID];
                if (missionList.count > 0)
                {
                    mission = [missionList objectAtIndex:0];
                    envoy.managedObjectID = mission.objectID;
                }
            }
        }
        
        if (!mission)
        {
            // This will create the Mission row.
            mission = [NSEntityDescription insertNewObjectForEntityForName:@"Mission" inManagedObjectContext:context];
            // This will associate the new row with the envoy, via the NSManagedObjectID.
            NSError *error = nil;
            [context obtainPermanentIDsForObjects:[NSArray arrayWithObject:mission] error:&error];
            if (!error)
            {
                envoy.managedObjectID = mission.objectID;
            }
        }
        
        [envoy commitInContext:context];
        [model addMissionsObject:mission];
    }
    
    
    
    // The Rounds.
    for (RoundEnvoy *envoy in self.roundEnvoys)
    {
        Round *round = nil;
        if (envoy.managedObjectID)
        {
            round = (Round *)[context objectWithID:envoy.managedObjectID];
        }
        
        // This could be an update from the host in which case we have to hook up to the correct via the intramural ID.
        if (!round)
        {
            if (envoy.intramuralID)
            {
                NSArray *list = [context fetchObjectArrayForEntityName:@"Round" withPredicateFormat:@"intramuralID == %@", envoy.intramuralID];
                if (list.count > 0)
                {
                    round = [list objectAtIndex:0];
                    envoy.managedObjectID = round.objectID;
                }
            }
        }
        
        if (!round)
        {
            // This will create the Round row.
            round = [NSEntityDescription insertNewObjectForEntityForName:@"Round" inManagedObjectContext:context];
            round.intramuralID = envoy.intramuralID;
            // This will associate the new row with the envoy, via the NSManagedObjectID.
            NSError *error = nil;
            [context obtainPermanentIDsForObjects:[NSArray arrayWithObject:round] error:&error];
            if (!error)
            {
                envoy.managedObjectID = round.objectID;
            }
        }
        
        [envoy commitInContext:context];
        [model addRoundsObject:round];
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
    
    // Make sure that intramuralID gets set.
    // It's not just for peer to peer: it's the glue that
    // holds it close to its child objects.
    if (!self.intramuralID)
    {
        self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        model.intramuralID = self.intramuralID;
    }
    
    for (GamePlayerEnvoy *envoy in self.gamePlayerEnvoys)
    {
        if (!envoy.gameID)
        {
            [envoy setGameID:self.intramuralID];
            [envoy commitInContext:context];
        }
    }
    
    for (MissionEnvoy *envoy in self.missionEnvoys)
    {
        if (!envoy.gameID)
        {
            [envoy setGameID:self.intramuralID];
            [envoy commitInContext:context];
        }
    }
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    // This is the outbound Managed Object ID to String tango.
//    if (self.managedObjectID)
//    {
//        NSString *objectIDString = [[self.managedObjectID URIRepresentation] absoluteString];
//        [aCoder encodeObject:objectIDString forKey:@"managedObjectID"];
//    }
    
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.endDate forKey:@"endDate"];
    [aCoder encodeInteger:self.numberOfPlayers forKey:@"numberOfPlayers"];
    [aCoder encodeObject:self.gamePlayerEnvoys forKey:@"gamePlayerEnvoys"];
    [aCoder encodeObject:self.missionEnvoys forKey:@"missionEnvoys"];
    [aCoder encodeObject:self.roundEnvoys forKey:@"roundEnvoys"];
    [aCoder encodeObject:self.modifiedDate forKey:@"modifiedDate"];
    [aCoder encodeInteger:self.gameCode forKey:@"gameCode"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
//        // This is the inbound String to Managed Object ID tango.
//        NSString *objectIDString = [aDecoder decodeObjectForKey:@"managedObjectID"];
//        if (objectIDString)
//        {
//            self.managedObjectID = [JSKDataMiner localObjectIDForImported:objectIDString];
//            if (!self.managedObjectID)
//            {
//                self.importedObjectString = objectIDString;
//                //                debugLog(@"managedObjectID not found in local store %@", objectIDString);
//            }
//        }
        
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
        self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
        self.numberOfPlayers = [aDecoder decodeIntegerForKey:@"numberOfPlayers"];
        self.gamePlayerEnvoys = [aDecoder decodeObjectForKey:@"gamePlayerEnvoys"];
        self.missionEnvoys = [aDecoder decodeObjectForKey:@"missionEnvoys"];
        self.roundEnvoys = [aDecoder decodeObjectForKey:@"roundEnvoys"];
        self.modifiedDate = [aDecoder decodeObjectForKey:@"modifiedDate"];
        self.gameCode = [aDecoder decodeIntegerForKey:@"gameCode"];
    }
    
    return self;
}

@end
