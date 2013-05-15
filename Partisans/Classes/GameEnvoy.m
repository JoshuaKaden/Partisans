//
//  GameEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameEnvoy.h"

#import "Game.h"
#import "JSKDataMiner.h"

@implementation GameEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize importedObjectString = m_importedObjectString;

@synthesize startDate = m_startDate;
@synthesize endDate = m_endDate;
@synthesize numberOfPlayers = m_numberOfPlayers;

- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_importedObjectString release];
    
    [m_startDate release];
    [m_endDate release];
    
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


- (NSArray *)players
{
    return nil;
}



#pragma mark - Commits

- (void)commit
{
    [self commitInContext:nil];
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
    }
    
    return self;
}

@end
