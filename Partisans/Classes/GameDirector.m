//
//  GameDirector.m
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
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

#import "GameDirector.h"

#import "GameEnvoy.h"
#import "GamePlayerEnvoy.h"
#import "GamePrecis.h"
#import "JSKCommandParcel.h"
#import "MissionEnvoy.h"
#import "NetworkManager.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"
#import "UpdateGameOperation.h"


@interface GameDirector ()

@property (nonatomic, strong) GameEnvoy *gameEnvoy;

- (void)chooseOperatives;
- (void)createMissions;
- (void)createRound;
- (NSArray *)generateMissionNames;
- (PlayerEnvoy *)chooseCoordinator;
- (NSUInteger)getNextRoundNumber;
- (void)saveGame;
- (BOOL)isGameOver;
- (NSUInteger)calculateOperativeCount:(NSUInteger)playerCount;
- (NSUInteger)calculateTeamCount:(NSUInteger)missionNumber playerCount:(NSUInteger)playerCount;

@end


@implementation GameDirector

@synthesize gameEnvoy = m_gameEnvoy;


- (GameEnvoy *)gameEnvoy
{
    // Heavy-handed method for ensuring a fresh game envoy.
    self.gameEnvoy = nil;
    if (!m_gameEnvoy)
    {
        self.gameEnvoy = [SystemMessage gameEnvoy];
    }
    return m_gameEnvoy;
}


#pragma mark - Public

- (void)startGame
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    
    [self chooseOperatives];
    [self createMissions];
    [self createRound];
    
    gameEnvoy.startDate = [NSDate date];
    
    [self saveGame];
    
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:[SystemMessage playerEnvoy].peerID object:gameEnvoy];
    [NetworkManager sendParcelToPlayers:parcel];
}

- (void)startMission
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    RoundEnvoy *currentRound = [gameEnvoy currentRound];
    MissionEnvoy *mission = [gameEnvoy currentMission];
    
    mission.coordinator = currentRound.coordinator;
    [mission applyTeamMembers:[currentRound candidates]];
    mission.hasStarted = YES;
    
    [self saveGame];
}

- (void)startNewRound
{
    if ([self isGameOver])
    {
        [self.gameEnvoy setEndDate:[NSDate date]];
    }
    else
    {
        [self createRound];
        [SystemMessage gameEnvoy].hasScoreBeenShown = NO;
    }
    [self saveGame];
}


#pragma mark - Private


- (BOOL)isGameOver
{
    BOOL returnValue = NO;
    
    // If the game already has an end date, then it's most definitely over.
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    if (gameEnvoy.endDate)
    {
        returnValue = YES;
    }

    // Does the current mission has at least one round for each player?
    // If so, that means the voting has gone around the table with no decision.
    // That means the game is over.
    if (!returnValue)
    {
        MissionEnvoy *currentMission = [gameEnvoy currentMission];
        if (currentMission.roundCount > gameEnvoy.numberOfPlayers)
        {
            returnValue = YES;
        }
    }
    
    // Have three missions succeeded? Have three missions failed?
    // If either, then the game is over.
    if (!returnValue)
    {
        NSUInteger successCount = 0;
        NSUInteger failCount = 0;
        for (MissionEnvoy *missionEnvoy in gameEnvoy.missionEnvoys)
        {
            if (missionEnvoy.isComplete)
            {
                if (missionEnvoy.didSucceed)
                {
                    successCount ++;
                }
                else
                {
                    failCount ++;
                }
            }
        }
        if (successCount > 2 || failCount > 2)
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)saveGame
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    [gameEnvoy commitAndSave];
}


- (void)sendGameUpdateTo:(NSString *)peerID modifiedDate:(NSDate *)modifiedDate shouldSendAllData:(BOOL)shouldSendAllData
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    NSString *hostID = [SystemMessage playerEnvoy].peerID;
    
    
    BOOL shouldProceed = NO;
    if (!modifiedDate)
    {
        shouldProceed = YES;
    }
    if (!shouldProceed)
    {
        if ([SystemMessage secondsBetweenDates:modifiedDate toDate:gameEnvoy.modifiedDate] > 0)
        {
            shouldProceed = YES;
        }
    }
    if (!shouldProceed)
    {
        return;
    }
    
    
    // Send the whole game if...
    // ...no modified date is specified,
    if (!modifiedDate)
    {
        shouldSendAllData = YES;
    }
    // ...the game is over,
    if (gameEnvoy.endDate)
    {
        shouldSendAllData = YES;
    }
    // ...there's no current round, or
    RoundEnvoy *currentRound = [gameEnvoy currentRound];
    if (!currentRound)
    {
        shouldSendAllData = YES;
    }
    // ...there's only one round.
    if (currentRound.roundNumber == 1)
    {
        shouldSendAllData = YES;
    }
    
    if (shouldSendAllData)
    {
        JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:peerID from:hostID object:gameEnvoy];
        if (peerID)
        {
            [NetworkManager sendCommandParcel:parcel shouldAwaitResponse:NO];
        }
        else
        {
            [NetworkManager sendParcelToPlayers:parcel];
        }
        return;
    }
    
    
    // Send a subset of the game data.
    // This is a favor to the bandwidth gods.
    RoundEnvoy *previousRound = nil;
    if (currentRound.roundNumber > 1)
    {
        previousRound = [gameEnvoy roundEnvoyFromNumber:currentRound.roundNumber - 1];
    }
    MissionEnvoy *currentMission = [gameEnvoy currentMission];
    MissionEnvoy *previousMission = nil;
    if (currentMission.missionNumber > 1)
    {
        previousMission = [gameEnvoy missionEnvoyFromNumber:currentMission.missionNumber - 1];
    }
    
    // Five possible objects: game precis, current round, previous round, current mission, previous mission.
    NSMutableArray *objectList = [[NSMutableArray alloc] initWithCapacity:5];
    GamePrecis *precis = [[GamePrecis alloc] initWithEnvoy:gameEnvoy];
    [objectList addObject:precis];
    if (previousRound)
    {
        [objectList addObject:previousRound];
    }
    if (previousMission)
    {
        [objectList addObject:previousMission];
    }
    [objectList addObject:currentRound];
    [objectList addObject:currentMission];
    NSArray *objectArray = [NSArray arrayWithArray:objectList];
    
    // Send the array of objects.
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:peerID from:hostID object:objectArray];
    if (peerID)
    {
        [NetworkManager sendCommandParcel:parcel shouldAwaitResponse:NO];
    }
    else
    {
        [NetworkManager sendParcelToPlayers:parcel];
    }
}



- (void)chooseOperatives
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    if (gameEnvoy.operativeCount > 0)
    {
        return;
    }
    
    NSArray *playerEnvoys = [gameEnvoy players];
    NSUInteger playerCount = playerEnvoys.count;
    NSUInteger operativeCount = [self calculateOperativeCount:playerEnvoys.count];
    if (operativeCount == 0)
    {
        // Invalid player count!
        return;
    }
    
    NSUInteger operativeOneIndex = arc4random() % playerCount;
    NSUInteger operativeTwoIndex = arc4random() % playerCount;
    while (operativeTwoIndex == operativeOneIndex)
    {
        operativeTwoIndex = arc4random() % playerCount;
    }
    
    PlayerEnvoy *operativeOne = [playerEnvoys objectAtIndex:operativeOneIndex];
    PlayerEnvoy *operativeTwo = [playerEnvoys objectAtIndex:operativeTwoIndex];
    
    GamePlayerEnvoy *gameOperativeOne = [gameEnvoy gamePlayerEnvoyFromPlayer:operativeOne];
    GamePlayerEnvoy *gameOperativeTwo = [gameEnvoy gamePlayerEnvoyFromPlayer:operativeTwo];
    
    gameOperativeOne.isOperative = YES;
    gameOperativeTwo.isOperative = YES;
    
    
    NSUInteger operativeThreeIndex;
    if (operativeCount > 2)
    {
        operativeThreeIndex = arc4random() % playerCount;
        while (operativeThreeIndex == operativeOneIndex || operativeThreeIndex == operativeTwoIndex)
        {
            operativeThreeIndex = arc4random() % playerCount;
        }
        PlayerEnvoy *operativeThree = [playerEnvoys objectAtIndex:operativeThreeIndex];
        GamePlayerEnvoy *gameOperativeThree = [gameEnvoy gamePlayerEnvoyFromPlayer:operativeThree];
        gameOperativeThree.isOperative = YES;
    }
    
    if (operativeCount > 3)
    {
        NSUInteger operativeFourIndex = arc4random() % playerCount;
        while (operativeFourIndex == operativeOneIndex || operativeFourIndex == operativeTwoIndex || operativeFourIndex == operativeThreeIndex)
        {
            operativeFourIndex = arc4random() % playerCount;
        }
        PlayerEnvoy *operativeFour = [playerEnvoys objectAtIndex:operativeFourIndex];
        GamePlayerEnvoy *gameOperativeFour = [gameEnvoy gamePlayerEnvoyFromPlayer:operativeFour];
        gameOperativeFour.isOperative = YES;
    }
}

- (NSUInteger)calculateOperativeCount:(NSUInteger)playerCount
{
    NSUInteger returnValue = 0;
    switch (playerCount)
    {
        case 5:
        case 6:
            returnValue = 2;
            break;
            
        case 7:
        case 8:
        case 9:
            returnValue = 3;
            break;
            
        case 10:
            returnValue = 4;
            break;
            
        default:
            break;
    }
    return returnValue;
}


- (void)createMissions
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    NSUInteger playerCount = [gameEnvoy players].count;
    
    // Create set of mission names.
    NSArray *missionNames = [self generateMissionNames];
    
    // Mission One.
    NSUInteger missionIndex = 0;
    MissionEnvoy *missionEnvoyOne = [[MissionEnvoy alloc] init];
    missionEnvoyOne.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyOne.missionNumber = missionIndex + 1;
    missionEnvoyOne.teamCount = [self calculateTeamCount:missionIndex + 1 playerCount:playerCount];
    [gameEnvoy addMission:missionEnvoyOne];
    
    // Mission Two.
    missionIndex++;
    MissionEnvoy *missionEnvoyTwo = [[MissionEnvoy alloc] init];
    missionEnvoyTwo.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyTwo.missionNumber = missionIndex + 1;
    missionEnvoyTwo.teamCount = [self calculateTeamCount:missionIndex + 1 playerCount:playerCount];
    [gameEnvoy addMission:missionEnvoyTwo];

    // Mission Three.
    missionIndex++;
    MissionEnvoy *missionEnvoyThree = [[MissionEnvoy alloc] init];
    missionEnvoyThree.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyThree.missionNumber = missionIndex + 1;
    missionEnvoyThree.teamCount = [self calculateTeamCount:missionIndex + 1 playerCount:playerCount];
    [gameEnvoy addMission:missionEnvoyThree];
    
    // Mission Four.
    missionIndex++;
    MissionEnvoy *missionEnvoyFour = [[MissionEnvoy alloc] init];
    missionEnvoyFour.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyFour.missionNumber = missionIndex + 1;
    missionEnvoyFour.teamCount = [self calculateTeamCount:missionIndex + 1 playerCount:playerCount];
    [gameEnvoy addMission:missionEnvoyFour];

    // Mission Five.
    missionIndex++;
    MissionEnvoy *missionEnvoyFive = [[MissionEnvoy alloc] init];
    missionEnvoyFive.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyFive.missionNumber = missionIndex + 1;
    missionEnvoyFive.teamCount = [self calculateTeamCount:missionIndex + 1 playerCount:playerCount];
    [gameEnvoy addMission:missionEnvoyFive];
}

- (NSUInteger)calculateTeamCount:(NSUInteger)missionNumber playerCount:(NSUInteger)playerCount
{
    NSUInteger returnValue = 0;
    switch (missionNumber)
    {
        case 1:
        {
            switch (playerCount)
            {
                case 5:
                case 6:
                case 7:
                    returnValue = 2;
                    break;
                case 8:
                case 9:
                case 10:
                    returnValue = 3;
                    break;
                default:
                    break;
            }
            break;
        }
            
        case 2:
        {
            switch (playerCount)
            {
                case 5:
                case 6:
                case 7:
                    returnValue = 3;
                    break;
                case 8:
                case 9:
                case 10:
                    returnValue = 4;
                    break;
                default:
                    break;
            }
            break;
        }
            
        case 3:
        {
            switch (playerCount)
            {
                case 5:
                    returnValue = 2;
                    break;
                case 6:
                    returnValue = 4;
                    break;
                case 7:
                    returnValue = 3;
                    break;
                case 8:
                case 9:
                case 10:
                    returnValue = 4;
                    break;
                default:
                    break;
            }
            break;
        }
            
        case 4:
        {
            switch (playerCount)
            {
                case 5:
                case 6:
                    returnValue = 3;
                    break;
                case 7:
                    returnValue = 4;
                    break;
                case 8:
                case 9:
                case 10:
                    returnValue = 5;
                    break;
                default:
                    break;
            }
            break;
        }
            
        case 5:
        {
            switch (playerCount)
            {
                case 5:
                    returnValue = 3;
                    break;
                case 6:
                case 7:
                    returnValue = 4;
                    break;
                case 8:
                case 9:
                case 10:
                    returnValue = 5;
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    return returnValue;
}

- (NSArray *)generateMissionNames
{
    NSString *name01 = NSLocalizedString(@"Scrambled Eggs", @"Scrambled Eggs  --  mission name");
    NSString *name02 = NSLocalizedString(@"Lemon Difficult", @"Lemon Difficult  --  mission name");
    NSString *name03 = NSLocalizedString(@"Blue Ant", @"Blue Ant  --  mission name");
    NSString *name04 = NSLocalizedString(@"Hollow Hills", @"Hollow Hills  --  mission name");
    NSString *name05 = NSLocalizedString(@"Long Nines", @"Long Nines  --  mission name");
    NSString *name06 = NSLocalizedString(@"Marthambles", @"Marthambles  --  mission name");
    NSString *name07 = NSLocalizedString(@"Woundwort", @"Woundwort  --  mission name");
    NSString *name08 = NSLocalizedString(@"That Child", @"That Child  --  mission name");
    NSString *name09 = NSLocalizedString(@"Barchester", @"Barchester  --  mission name");
    NSString *name10 = NSLocalizedString(@"Steel Birds", @"Steel Birds  --  mission name");
    NSString *name11 = NSLocalizedString(@"Hat Creek", @"Hat Creek  --  mission name");
    NSString *name12 = NSLocalizedString(@"Gentleman Ghost", @"Gentleman Ghost  --  mission name");
    NSString *name13 = NSLocalizedString(@"Perfect Blue", @"Perfect Blue  --  mission name");
    NSString *name14 = NSLocalizedString(@"Shooting Star", @"Shooting Star  --  mission name");
    NSString *name15 = NSLocalizedString(@"Vanilla Chicken", @"Vanilla Chicken  --  mission name");
    NSString *name16 = NSLocalizedString(@"Poor Swab", @"Poor Swab  --  mission name");
    NSString *name17 = NSLocalizedString(@"Magic Dragon", @"Magic Dragon  --  mission name");
    NSString *name18 = NSLocalizedString(@"Sunnydale", @"Sunnydale  --  mission name");
    NSString *name19 = NSLocalizedString(@"Browncoats", @"Browncoats  --  mission name");
    NSString *name20 = NSLocalizedString(@"Harum-scarum", @"Harum-scarum  --  mission name");
    NSArray *unshuffled = [NSArray arrayWithObjects:name01, name02, name03, name04, name05, name06, name07, name08, name09, name10, name11, name12, name13, name14, name15, name16, name17, name18, name19, name20, nil];

    NSMutableArray *shuffledList = [[NSMutableArray alloc] initWithArray:unshuffled];
    NSUInteger count = [shuffledList count];
    for (NSUInteger i = 0; i < count; i++)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = (int)count - (int)i;
        int n = (arc4random() % nElements) + (int)i;
        [shuffledList exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSArray *shuffled = [[NSArray alloc] initWithArray:shuffledList];
    
    NSRange range = NSRangeFromString(@"{0,5}");
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:range];
    NSArray *returnValue = [shuffled objectsAtIndexes:indexSet];
    
    return returnValue;
}

- (void)createRound
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    MissionEnvoy *currentMission = [gameEnvoy firstIncompleteMission];
    PlayerEnvoy *coordinator = [self chooseCoordinator];
    NSUInteger roundNumber = [self getNextRoundNumber];
    
    RoundEnvoy *roundEnvoy = [[RoundEnvoy alloc] init];
    roundEnvoy.roundNumber = roundNumber;
    roundEnvoy.gameID = gameEnvoy.intramuralID;
    roundEnvoy.coordinatorID = coordinator.intramuralID;
    roundEnvoy.missionNumber = currentMission.missionNumber;
    
    [gameEnvoy addRound:roundEnvoy];
}


- (PlayerEnvoy *)chooseCoordinator
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    PlayerEnvoy *returnValue = nil;
    NSArray *players = self.gameEnvoy.players;
    NSUInteger playerCount = players.count;
    NSArray *candidates = nil;
    
    NSUInteger newRoundIndex = [self getNextRoundNumber];
    
    if (gameEnvoy.roundCount >= playerCount)
    {
        // We'll use the same order as before.
        RoundEnvoy *historicRound = [gameEnvoy roundEnvoyFromNumber:newRoundIndex - playerCount];
        PlayerEnvoy *coordinator = [PlayerEnvoy envoyFromIntramuralID:historicRound.coordinatorID];
        return coordinator;
    }
    
    if (gameEnvoy.roundCount == 0)
    {
        // First round; so all players are candidates.
        candidates = players;
    }
    else
    {
        // Build a list of the previous coordinators, and select someone who hasn't yet had a turn.
        NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:playerCount];
        for (int i = 1; i < newRoundIndex; i++)
        {
            RoundEnvoy *round = [gameEnvoy roundEnvoyFromNumber:i];
            for (PlayerEnvoy *envoy in players)
            {
                if ([envoy.intramuralID isEqualToString:round.coordinatorID])
                {
                    [list addObject:envoy];
                    break;
                }
            }
        }
        NSMutableArray *playerList = [[NSMutableArray alloc] initWithArray:players];
        [playerList removeObjectsInArray:list];
        candidates = [NSArray arrayWithArray:playerList];
    }
    
    if (candidates)
    {
        if (candidates.count == 1)
        {
            returnValue = [candidates objectAtIndex:0];
        }
        else
        {
            NSUInteger coordinatorIndex = arc4random() % (candidates.count - 1);
            returnValue = [candidates objectAtIndex:coordinatorIndex];
        }
    }
    return returnValue;
}


- (NSUInteger)getNextRoundNumber
{
    return self.gameEnvoy.roundCount + 1;
}


@end
