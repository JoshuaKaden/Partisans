//
//  GameEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameEnvoy.h"

#import "Game.h"
#import "GamePlayer.h"
#import "GamePlayerEnvoy.h"
#import "JSKDataMiner.h"
#import "Mission.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface GameEnvoy ()
@property (nonatomic, strong) NSArray *gamePlayerEnvoys;
- (void)loadGamePlayerEnvoys;
@end


@implementation GameEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize importedObjectString = m_importedObjectString;

@synthesize startDate = m_startDate;
@synthesize endDate = m_endDate;
@synthesize numberOfPlayers = m_numberOfPlayers;
@synthesize gamePlayerEnvoys = m_gamePlayerEnvoys;

- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_importedObjectString release];
    
    [m_startDate release];
    [m_endDate release];
    [m_gamePlayerEnvoys release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(Game *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID = managedObject.intramuralID;
        
        self.startDate = managedObject.startDate;
        self.endDate = managedObject.endDate;
        self.numberOfPlayers = [managedObject.numberOfPlayers unsignedIntegerValue];
        
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
            //            self.isNative = YES;
        }
        
        [self loadGamePlayerEnvoys];
    }
    
    return self;
}


+ (GameEnvoy *)envoyFromManagedObject:(Game *)managedObject
{
    GameEnvoy *envoy = [[[GameEnvoy alloc] initWithManagedObject:managedObject] autorelease];
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
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"GameEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              importedObjectString, @"importedObjectString",
                              managedObjectString, @"managedObjectID",
                              startDateString, @"startDate",
                              endDateString, @"endDate",
                              [NSNumber numberWithUnsignedInteger:self.numberOfPlayers].description, @"numberOfPlayers", nil];
    return descDict.description;
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
        if (player.gamePlayer.isHost)
        {
            Game *game = player.gamePlayer.game;
            returnValue = [GameEnvoy envoyFromManagedObject:game];
        }
    }
    
    return returnValue;
}


+ (GameEnvoy *)createGame
{
    // Create the game itself.
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *newGame = (Game *)[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
    newGame.numberOfPlayers = [NSNumber numberWithInt:5];
    
    // Add the host.
    PlayerEnvoy *hostEnvoy = [SystemMessage playerEnvoy];
    Player *host = (Player *)[context objectWithID:hostEnvoy.managedObjectID];
    GamePlayer *gamePlayer = (GamePlayer *)[NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
    gamePlayer.player = host;
    gamePlayer.isHost = [NSNumber numberWithBool:YES];
    [newGame addGamePlayersObject:gamePlayer];
    
    // Add the missions.
    for (NSUInteger missionIndex = 0; missionIndex < 5; missionIndex++)
    {
        Mission *mission = (Mission *)[NSEntityDescription insertNewObjectForEntityForName:@"Mission" inManagedObjectContext:context];
        mission.missionNumber = [NSNumber numberWithUnsignedInteger:missionIndex + 1];
        [newGame addMissionsObject:mission];
    }
    
    [JSKDataMiner save];
    
    GameEnvoy *returnValue = [GameEnvoy envoyFromManagedObject:newGame];
    return returnValue;
}


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
    
    NSSet *playerSet = game.gamePlayers;
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"player.playerName" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:nameSort, nil];
    [nameSort release];
    NSArray *gamePlayers = [playerSet sortedArrayUsingDescriptors:sorts];
    [sorts release];
    
    NSMutableArray *envoyList = [[NSMutableArray alloc] initWithCapacity:gamePlayers.count];
    for (GamePlayer *gamePlayer in gamePlayers)
    {
        GamePlayerEnvoy *envoy = [[GamePlayerEnvoy alloc] initWithManagedObject:gamePlayer];
        [envoyList addObject:envoy];
        [envoy release];
    }
    
    [self setGamePlayerEnvoys:[NSArray arrayWithArray:envoyList]];
    [envoyList release];
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
    [nameSort release];
    NSArray *players = [playerSet sortedArrayUsingDescriptors:sorts];
    [sorts release];
    
    NSMutableArray *envoys = [[NSMutableArray alloc] initWithCapacity:players.count];
    for (GamePlayer *gamePlayer in players)
    {
        PlayerEnvoy *envoy = [[PlayerEnvoy alloc] initWithManagedObject:gamePlayer.player];
        [envoys addObject:envoy];
        [envoy release];
    }
    
    NSArray *returnValue = [NSArray arrayWithArray:envoys];
    [envoys release];
    
    return returnValue;
}


- (PlayerEnvoy *)host
{
    PlayerEnvoy *returnValue = nil;
    
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    for (GamePlayer *gamePlayer in game.gamePlayers)
    {
        if (gamePlayer.isHost)
        {
            returnValue = [PlayerEnvoy envoyFromManagedObject:gamePlayer.player];
            break;
        }
    }
    
    return returnValue;
}


- (void)addPlayer:(PlayerEnvoy *)playerEnvoy
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    Player *player = (Player *)[context objectWithID:playerEnvoy.managedObjectID];
    GamePlayer *gamePlayer = (GamePlayer *)[NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
    gamePlayer.player = player;
    Game *game = (Game *)[context objectWithID:self.managedObjectID];
    [game addGamePlayersObject:gamePlayer];
}


#pragma mark - Commits

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
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.startDate = self.startDate;
    model.endDate = self.endDate;
    model.numberOfPlayers = [NSNumber numberWithUnsignedInteger:self.numberOfPlayers];
    
    if (self.gamePlayerEnvoys)
    {
        for (GamePlayerEnvoy *envoy in self.gamePlayerEnvoys)
        {
            [envoy commitInContext:context];
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
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // This is the outbound Managed Object ID to String tango.
    if (self.managedObjectID)
    {
        NSString *objectIDString = [[self.managedObjectID URIRepresentation] absoluteString];
        [aCoder encodeObject:objectIDString forKey:@"managedObjectID"];
    }
    
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.endDate forKey:@"endDate"];
    [aCoder encodeInteger:self.numberOfPlayers forKey:@"numberOfPlayers"];
    [aCoder encodeObject:self.gamePlayerEnvoys forKey:@"gamePlayerEnvoys"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        // This is the inbound String to Managed Object ID tango.
        NSString *objectIDString = [aDecoder decodeObjectForKey:@"managedObjectID"];
        if (objectIDString)
        {
            self.managedObjectID = [JSKDataMiner localObjectIDForImported:objectIDString];
            if (!self.managedObjectID)
            {
                self.importedObjectString = objectIDString;
                //                debugLog(@"managedObjectID not found in local store %@", objectIDString);
            }
        }
        
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
        self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
        self.numberOfPlayers = [aDecoder decodeIntegerForKey:@"numberOfPlayers"];
        self.gamePlayerEnvoys = [aDecoder decodeObjectForKey:@"gamePlayerEnvoys"];
    }
    
    return self;
}

@end
