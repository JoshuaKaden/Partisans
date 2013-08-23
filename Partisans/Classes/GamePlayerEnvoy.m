//
//  GamePlayerEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 5/18/13.
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
@synthesize hasAlertBeenShown = m_hasAlertBeenShown;

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
        self.hasAlertBeenShown = [managedObject.hasAlertBeenShown boolValue];
        self.playerID = managedObject.player.intramuralID;
        self.gameID = managedObject.game.intramuralID;
        
        self.intramuralID = managedObject.intramuralID;
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
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
                              [NSNumber numberWithBool:self.hasAlertBeenShown].description, @"hasAlertBeenShown",
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
        if (self.intramuralID)
        {
            NSArray *list = [context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (list.count > 0)
            {
                model = [list objectAtIndex:0];
                self.managedObjectID = model.objectID;
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"GamePlayer" inManagedObjectContext:context];
        model.hasAlertBeenShown = [NSNumber numberWithBool:NO];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.isHost = [NSNumber numberWithBool:self.isHost];
    model.isOperative = [NSNumber numberWithBool:self.isOperative];
    
    // This attribute only gets set to YES once, by the player.
    // So don't update it unless it is NO.
    if (![model.hasAlertBeenShown boolValue])
    {
        model.hasAlertBeenShown = [NSNumber numberWithBool:self.hasAlertBeenShown];
    }

    // Set the player.
    if (self.playerID && !model.player)
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
//    // This is the outbound Managed Object ID to String tango.
//    if (self.managedObjectID)
//    {
//        NSString *objectIDString = [[self.managedObjectID URIRepresentation] absoluteString];
//        [aCoder encodeObject:objectIDString forKey:@"managedObjectID"];
//    }
    
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    
    [aCoder encodeBool:self.isHost forKey:@"isHost"];
    [aCoder encodeBool:self.isOperative forKey:@"isOperative"];
    [aCoder encodeObject:self.playerID forKey:@"playerID"];
    [aCoder encodeObject:self.gameID forKey:@"gameID"];
    [aCoder encodeBool:self.hasAlertBeenShown forKey:@"hasAlertBeenShown"];
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
        
        self.isHost = [aDecoder decodeBoolForKey:@"isHost"];
        self.isOperative = [aDecoder decodeBoolForKey:@"isOperative"];
        self.playerID = [aDecoder decodeObjectForKey:@"playerID"];
        self.gameID = [aDecoder decodeObjectForKey:@"gameID"];
        self.hasAlertBeenShown = [aDecoder decodeBoolForKey:@"hasAlertBeenShown"];
    }
    
    return self;
}

@end
