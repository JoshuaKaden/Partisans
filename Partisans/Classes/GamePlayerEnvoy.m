//
//  GamePlayerEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 5/18/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GamePlayerEnvoy.h"

#import "Game.h"
#import "GameEnvoy.h"
#import "GamePlayer.h"
#import "JSKDataMiner.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "SystemMessage.h"


@interface GamePlayerEnvoy ()
@end


@implementation GamePlayerEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize importedObjectString = m_importedObjectString;
@synthesize isHost = m_isHost;
@synthesize isOperative = m_isOperative;
@synthesize playerID = m_playerID;
@synthesize gameID = m_gameID;

- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_importedObjectString release];
    [m_playerID release];
    [m_gameID release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(GamePlayer *)managedObject
{
    self = [super init];
    if (self)
    {
        self.isHost = [managedObject.isHost boolValue];
        self.isOperative = [managedObject.isOperative boolValue];
        self.playerID = managedObject.player.intramuralID;
        self.gameID = managedObject.game.intramuralID;
        
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
            //            self.isNative = YES;
        }
    }
    
    return self;
}


+ (GamePlayerEnvoy *)envoyFromManagedObject:(GamePlayer *)managedObject
{
    GamePlayerEnvoy *envoy = [[[GamePlayerEnvoy alloc] initWithManagedObject:managedObject] autorelease];
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
    
    NSString *playerIDString = self.playerID;
    if (!playerIDString)
    {
        playerIDString = @"";
    }

    NSString *gameIDString = self.gameID;
    if (!gameIDString)
    {
        gameIDString = @"";
    }

    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"GamePlayerEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              importedObjectString, @"importedObjectString",
                              managedObjectString, @"managedObjectID",
                              [NSNumber numberWithBool:self.isHost].description, @"isHost",
                              [NSNumber numberWithBool:self.isOperative].description, @"isOperative",
                              playerIDString, @"playerID",
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
    
    GamePlayer *model = nil;
    if (self.managedObjectID)
    {
        model = (GamePlayer *)[context objectWithID:self.managedObjectID];
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.isHost = [NSNumber numberWithBool:self.isHost];
    model.isOperative = [NSNumber numberWithBool:self.isOperative];

    // Set the player.
    if (self.playerID)
    {
        NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"intramuralID == %@", self.playerID];
        if (players.count > 0)
        {
            Player *player = [players objectAtIndex:0];
            model.player = player;
        }
    }
    else
    {
        // Error state?
    }
    
    
    // Set the game.
    if (self.gameID)
    {
        // Assuming that we're working with a single game, which ought to be the SysMsg's game.
        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
        if (![self.gameID isEqualToString:gameEnvoy.intramuralID])
        {
            // Error state
            return;
        }
        Game *game = (Game *)[context objectWithID:gameEnvoy.managedObjectID];
        model.game = game;
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
    
    [aCoder encodeBool:self.isHost forKey:@"isHost"];
    [aCoder encodeBool:self.isOperative forKey:@"isOperative"];
    [aCoder encodeObject:self.playerID forKey:@"playerID"];
    [aCoder encodeObject:self.gameID forKey:@"gameID"];
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
        
        self.isHost = [aDecoder decodeBoolForKey:@"isHost"];
        self.isOperative = [aDecoder decodeBoolForKey:@"isOperative"];
        self.playerID = [aDecoder decodeObjectForKey:@"playerID"];
        self.gameID = [aDecoder decodeObjectForKey:@"gameID"];
    }
    
    return self;
}

@end
