//
//  GameDirector.m
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameDirector.h"

#import "GameEnvoy.h"
#import "GamePlayerEnvoy.h"
#import "GamePrecis.h"
#import "JSKCommandParcel.h"
#import "MissionEnvoy.h"
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

@end


@implementation GameDirector

@synthesize gameEnvoy = m_gameEnvoy;

- (void)dealloc
{
    [m_gameEnvoy release];
    [super dealloc];
}

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
    [SystemMessage sendParcelToPlayers:parcel];
    [parcel release];
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
        if (currentMission.roundCount >= gameEnvoy.numberOfPlayers)
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
    
//    NSDate *oldDate = [NSDate distantPast];
//    [self sendGameUpdateTo:nil modifiedDate:oldDate shouldSendAllData:NO];

//    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:[SystemMessage playerEnvoy].peerID object:gameEnvoy];
//    [SystemMessage sendParcelToPlayers:parcel];
//    [parcel release];
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
            [SystemMessage sendCommandParcel:parcel shouldAwaitResponse:NO];
        }
        else
        {
            [SystemMessage sendParcelToPlayers:parcel];
        }
        [parcel release];
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
    [precis release];
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
    [objectList release];
    
    // Send the array of objects.
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:peerID from:hostID object:objectArray];
    if (peerID)
    {
        [SystemMessage sendCommandParcel:parcel shouldAwaitResponse:NO];
    }
    else
    {
        [SystemMessage sendParcelToPlayers:parcel];
    }
    [parcel release];
}



- (void)chooseOperatives
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    if (gameEnvoy.operativeCount > 0)
    {
        return;
    }
    
    NSArray *playerEnvoys = [gameEnvoy players];
    
    NSUInteger operativeOneIndex = arc4random() % playerEnvoys.count;
    NSUInteger operativeTwoIndex = arc4random() % playerEnvoys.count;
    while (operativeTwoIndex == operativeOneIndex)
    {
        operativeTwoIndex = arc4random() % playerEnvoys.count;
    }
    
    PlayerEnvoy *operativeOne = [playerEnvoys objectAtIndex:operativeOneIndex];
    PlayerEnvoy *operativeTwo = [playerEnvoys objectAtIndex:operativeTwoIndex];
    
    GamePlayerEnvoy *gameOperativeOne = [gameEnvoy gamePlayerEnvoyFromPlayer:operativeOne];
    GamePlayerEnvoy *gameOperativeTwo = [gameEnvoy gamePlayerEnvoyFromPlayer:operativeTwo];
    
    gameOperativeOne.isOperative = YES;
    gameOperativeTwo.isOperative = YES;
}

- (void)createMissions
{
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    
    // Create set of mission names.
    NSArray *missionNames = [self generateMissionNames];
    
    // Mission One.
    NSUInteger missionIndex = 0;
    MissionEnvoy *missionEnvoyOne = [[MissionEnvoy alloc] init];
    missionEnvoyOne.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyOne.missionNumber = missionIndex + 1;
    missionEnvoyOne.teamCount = 2;
    [gameEnvoy addMission:missionEnvoyOne];
    [missionEnvoyOne release];
    
    // Mission Two.
    missionIndex++;
    MissionEnvoy *missionEnvoyTwo = [[MissionEnvoy alloc] init];
    missionEnvoyTwo.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyTwo.missionNumber = missionIndex + 1;
    missionEnvoyTwo.teamCount = 3;
    [gameEnvoy addMission:missionEnvoyTwo];
    [missionEnvoyTwo release];

    // Mission Three.
    missionIndex++;
    MissionEnvoy *missionEnvoyThree = [[MissionEnvoy alloc] init];
    missionEnvoyThree.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyThree.missionNumber = missionIndex + 1;
    missionEnvoyThree.teamCount = 2;
    [gameEnvoy addMission:missionEnvoyThree];
    [missionEnvoyThree release];
    
    // Mission Four.
    missionIndex++;
    MissionEnvoy *missionEnvoyFour = [[MissionEnvoy alloc] init];
    missionEnvoyFour.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyFour.missionNumber = missionIndex + 1;
    missionEnvoyFour.teamCount = 3;
    [gameEnvoy addMission:missionEnvoyFour];
    [missionEnvoyFour release];

    // Mission Five.
    missionIndex++;
    MissionEnvoy *missionEnvoyFive = [[MissionEnvoy alloc] init];
    missionEnvoyFive.missionName = [missionNames objectAtIndex:missionIndex];
    missionEnvoyFive.missionNumber = missionIndex + 1;
    missionEnvoyFive.teamCount = 3;
    [gameEnvoy addMission:missionEnvoyFive];
    [missionEnvoyFive release];
}

- (NSArray *)generateMissionNames
{
    NSString *name1 = NSLocalizedString(@"Scrambled Eggs", @"Scrambled Eggs  --  mission name");
    NSString *name2 = NSLocalizedString(@"Lemon Difficult", @"Lemon Difficult  --  mission name");
    NSString *name3 = NSLocalizedString(@"Blue Ant", @"Blue Ant  --  mission name");
    NSString *name4 = NSLocalizedString(@"Hollow Hills", @"Hollow Hills  --  mission name");
    NSString *name5 = NSLocalizedString(@"Long Nines", @"Long Nines  --  mission name");
    return [NSArray arrayWithObjects:name1, name2, name3, name4, name5, nil];
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
    [roundEnvoy release];
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
        [list release];
        candidates = [NSArray arrayWithArray:playerList];
        [playerList release];
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
