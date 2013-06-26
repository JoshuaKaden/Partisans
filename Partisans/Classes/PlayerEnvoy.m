//
//  PlayerEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 4/21/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "PlayerEnvoy.h"

#import "Image.h"
#import "ImageEnvoy.h"
#import "JSKDataMiner.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "SystemMessage.h"


@interface PlayerEnvoy ()

@property (nonatomic, strong) NSArray *addedSightings;

@end


@implementation PlayerEnvoy


@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize playerName = m_playerName;
@synthesize importedObjectString = m_importedObjectString;
@synthesize isDefault = m_isDefault;
@synthesize isNative = m_isNative;
@synthesize favoriteColor = m_favoriteColor;
@synthesize picture = m_picture;
@synthesize isDefaultPicture = m_isDefaultPicture;
@synthesize addedSightings = m_addedSightings;
@synthesize peerID = m_peerID;
@synthesize modifiedDate = m_modifiedDate;


- (void)dealloc
{
    [m_managedObjectID release];
    [m_intramuralID release];
    [m_importedObjectString release];
    [m_playerName release];
    [m_favoriteColor release];
    [m_picture release];
    [m_addedSightings release];
    [m_peerID release];
    [m_modifiedDate release];
    
    [super dealloc];
}


- (id)initWithManagedObject:(Player *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID = managedObject.intramuralID;
        self.isDefault = [managedObject.isDefault boolValue];
        self.isNative = [managedObject.isNative boolValue];
        self.isDefaultPicture = [managedObject.isDefaultPicture boolValue];
        self.playerName = managedObject.playerName;
        self.favoriteColor = managedObject.favoriteColor;
        self.picture = [ImageEnvoy envoyFromManagedObject:managedObject.picture];
        self.peerID = managedObject.peerID;

        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
            self.isNative = YES;
        }
        
        if (!self.peerID)
        {
            self.peerID = self.intramuralID;
            managedObject.peerID = self.peerID;
//            // I'm having to work quite hard here to get the Peer ID to stick!
//            [self commitInContext:managedObject.managedObjectContext];
        }
        
        self.modifiedDate = managedObject.modifiedDate;
    }
    
    return self;
}


#pragma mark - Class methods

+ (PlayerEnvoy *)createEnvoyWithPeerID:(NSString *)peerID
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"peerID == %@", peerID];
    if (players.count > 0)
    {
        return nil;
    }
    
    PlayerEnvoy *newEnvoy = [[[PlayerEnvoy alloc] init] autorelease];
    newEnvoy.peerID = peerID;
    newEnvoy.intramuralID = peerID;
    return newEnvoy;
}

+ (PlayerEnvoy *)envoyFromIntramuralID:(NSString *)intramuralID
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"intramuralID == %@", intramuralID];
    
    if (players.count == 0)
    {
        return nil;
    }
    
    Player *player = [players objectAtIndex:0];
    return [self envoyFromManagedObject:player];
}

+ (PlayerEnvoy *)envoyFromPeerID:(NSString *)peerID
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"peerID == %@", peerID];
    
    if (players.count == 0)
    {
        return nil;
    }
    
    Player *player = [players objectAtIndex:0];
    return [self envoyFromManagedObject:player];
}



+ (PlayerEnvoy *)envoyFromManagedObject:(Player *)managedObject
{
    PlayerEnvoy *envoy = [[[PlayerEnvoy alloc] initWithManagedObject:managedObject] autorelease];
    return envoy;
}


+ (PlayerEnvoy *)defaultEnvoy
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSNumber *yesNumber = [NSNumber numberWithBool:YES];
    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"isDefault == %@ AND isNative == %@", yesNumber, yesNumber];
    
    PlayerEnvoy *envoy = nil;
    
    if (players.count > 0)
    {
        Player *player = [players objectAtIndex:0];
        envoy = [[[PlayerEnvoy alloc] initWithManagedObject:player] autorelease];
    }
    else
    {
        NSArray *localPlayerEnvoys = [self nativePlayers];
        if (localPlayerEnvoys.count > 0)
        {
            envoy = [localPlayerEnvoys objectAtIndex:0];
            envoy.isDefault = YES;
            [envoy commitAndSave];
        }
        else
        {
            envoy = [[[PlayerEnvoy alloc] init] autorelease];
            envoy.isNative = YES;
            envoy.isDefault = YES;
            envoy.favoriteColor = [UIColor grayColor];
            envoy.isDefaultPicture = YES;
        }
    }
    
    return envoy;
}


+ (NSArray *)nativePlayers
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSNumber *yesNumber = [NSNumber numberWithBool:YES];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"playerName" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:nameSort, nil];
    [nameSort release];
    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" usingSortDescriptors:sorts withPredicateFormat:@"isNative == %@", yesNumber];
    [sorts release];
    
    NSMutableArray *envoys = [[NSMutableArray alloc] initWithCapacity:players.count];
    for (Player *player in players)
    {
        PlayerEnvoy *envoy = [[PlayerEnvoy alloc] initWithManagedObject:player];
        [envoys addObject:envoy];
        [envoy release];
    }
    
    NSArray *returnValue = [NSArray arrayWithArray:envoys];
    [envoys release];
    
    return returnValue;
}

+ (NSArray *)peerPlayers
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    NSNumber *noNumber = [NSNumber numberWithBool:NO];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"playerName" ascending:YES];
    NSArray *sorts = [[NSArray alloc] initWithObjects:nameSort, nil];
    [nameSort release];
    NSArray *players = [context fetchObjectArrayForEntityName:@"Player" usingSortDescriptors:sorts withPredicateFormat:@"isNative == %@", noNumber];
    [sorts release];
    
    NSMutableArray *envoys = [[NSMutableArray alloc] initWithCapacity:players.count];
    for (Player *player in players)
    {
        PlayerEnvoy *envoy = [[PlayerEnvoy alloc] initWithManagedObject:player];
        [envoys addObject:envoy];
        [envoy release];
    }
    
    NSArray *returnValue = [NSArray arrayWithArray:envoys];
    [envoys release];
    
    return returnValue;
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
    
    NSString *aliasString = self.playerName;
    if (!aliasString)
    {
        aliasString= @"";
    }
    
    NSString *faveColorString = self.favoriteColor.description;
    if (!faveColorString)
    {
        faveColorString = @"";
    }
    
    NSString *peerIDString = self.peerID;
    if (!peerIDString)
    {
        peerIDString = @"";
    }
    
    NSString *modifiedDateString = self.modifiedDate.description;
    if (!modifiedDateString)
    {
        modifiedDateString = @"";
    }
    
    NSString *pictureString = self.picture.description;
    if (!pictureString)
    {
        pictureString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"PlayerEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              importedObjectString, @"importedObjectString",
                              managedObjectString, @"managedObjectID",
                              aliasString, @"playerName",
                              [NSNumber numberWithBool:self.isNative].description, @"isNative",
                              [NSNumber numberWithBool:self.isDefault].description, @"isDefault",
                              faveColorString, @"favoriteColor",
                              peerIDString, @"peerID",
                              modifiedDateString, @"modifiedDate",
                              pictureString, @"picture", nil];
    return descDict.description;
}



#pragma mark - Commits

- (void)deletePlayer
{
    NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
    if (!self.managedObjectID)
    {
        // Bail in this case.
        // Should not happen however.
        return;
    }
    Player *player = (Player *)[context objectWithID:self.managedObjectID];
    if (!player)
    {
        // Something badly wrong in this case.
        debugLog(@"Problem!!");
        return;
    }
    
    [context deleteObject:player];
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
    
    Player *model = nil;
    if (self.managedObjectID)
    {
        model = (Player *)[context objectWithID:self.managedObjectID];
    }
    
    // Safety net in case the model was created on another thread.
    if (!model)
    {
        if (self.intramuralID)
        {
            NSArray *players = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (players.count > 0)
            {
                model = [players objectAtIndex:0];
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
    }
    
    
    if (self.isDefault)
    {
        // Ensure that no one else is marked as default.
        NSArray *oldDefaults = [context fetchObjectArrayForEntityName:@"Player" withPredicateFormat:@"isDefault == %@", [NSNumber numberWithBool:YES]];
        for (Player *oldDefault in oldDefaults)
        {
            oldDefault.isDefault = [NSNumber numberWithBool:NO];
        }
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
    
    
    
    model.playerName = self.playerName;
    model.intramuralID = self.intramuralID;
    model.isDefault = [NSNumber numberWithBool:self.isDefault];
    model.isNative = [NSNumber numberWithBool:self.isNative];
    model.favoriteColor = self.favoriteColor;
    model.isDefaultPicture = [NSNumber numberWithBool:self.isDefaultPicture];
    model.peerID = self.peerID;
    model.modifiedDate = self.modifiedDate;
    
    if (self.picture)
    {
        [self.picture commitInContext:context];
        if (self.picture.managedObjectID)
        {
            Image *picture = (Image *)[context objectWithID:self.picture.managedObjectID];
            model.picture = picture;
        }
        else
        {
            model.picture = nil;
        }
    }
    else
    {
        model.picture = nil;
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
        self.isNative = YES;
        model.intramuralID = self.intramuralID;
    }
    
    if (!self.peerID)
    {
        self.peerID = self.intramuralID;
        model.peerID = self.peerID;
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
    
    [aCoder encodeObject:self.playerName forKey:@"playerName"];
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    [aCoder encodeBool:self.isNative forKey:@"isNative"];
    [aCoder encodeBool:self.isDefault forKey:@"isDefault"];
    [aCoder encodeObject:self.favoriteColor forKey:@"favoriteColor"];
    
    [aCoder encodeObject:self.picture forKey:@"picture"];
//    // Skip encoding the picture if it is the default picture.
//    // This way we save some bandwidth.
//    // The default picture can be reconstructed on the other side.
//    if (!self.isDefaultPicture)
//    {
//        [aCoder encodeObject:self.picture forKey:@"picture"];
//    }
    
    [aCoder encodeBool:self.isDefaultPicture forKey:@"isDefaultPicture"];
    [aCoder encodeObject:self.peerID forKey:@"peerID"];
    [aCoder encodeObject:self.modifiedDate forKey:@"modifiedDate"];
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
        
        self.playerName = [aDecoder decodeObjectForKey:@"playerName"];
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        self.isNative = [aDecoder decodeBoolForKey:@"isNative"];
        self.isDefault = [aDecoder decodeBoolForKey:@"isDefault"];
        self.favoriteColor = [aDecoder decodeObjectForKey:@"favoriteColor"];
        self.picture = [aDecoder decodeObjectForKey:@"picture"];
        self.isDefaultPicture = [aDecoder decodeBoolForKey:@"isDefaultPicture"];
        self.peerID = [aDecoder decodeObjectForKey:@"peerID"];
        self.modifiedDate = [aDecoder decodeObjectForKey:@"modifiedDate"];
    }
    
    return self;
}

@end
