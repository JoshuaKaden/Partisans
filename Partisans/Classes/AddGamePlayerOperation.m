//
//  AddGamePlayerOperation.m
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "AddGamePlayerOperation.h"

#import "GameEnvoy.h"
#import "JSKDataMiner.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"

#import <CoreData/CoreData.h>


@interface AddGamePlayerOperation ()

@property (nonatomic, strong) PlayerEnvoy *playerEnvoy;
@property (nonatomic, strong) GameEnvoy *gameEnvoy;

- (void)mergeChanges:(NSNotification *)notification;

@end



@implementation AddGamePlayerOperation

@synthesize playerEnvoy = m_playerEnvoy;
@synthesize gameEnvoy = m_gameEnvoy;


- (void)dealloc
{
    [m_playerEnvoy release];
    [m_gameEnvoy release];
    [super dealloc];
}


- (id)initWithPlayerEnvoy:(PlayerEnvoy *)playerEnvoy gameEnvoy:(GameEnvoy *)gameEnvoy
{
    self = [super init];
    if (self)
    {
        self.playerEnvoy = playerEnvoy;
        self.gameEnvoy = gameEnvoy;
    }
    return self;
}



- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create context on background thread
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setUndoManager:nil];
    [context setPersistentStoreCoordinator:[JSKDataMiner sharedInstance].persistentStoreCoordinator];
    
    
    // Register context with the notification center
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
    
    
    
    
    // Here is the actual work of the class.
    [self.gameEnvoy addPlayer:self.playerEnvoy];
    [self.gameEnvoy commitInContext:context];
    
    
    
    
    NSError *error = nil;
    if (context && [context hasChanges])
    {
        if (![context save:&error]) {
            debugLog(@"*** Error saving context: %@",[error localizedDescription]);
        }
    }
    
    
    
    [context release];
    
    [notificationCenter removeObserver:self];
    [pool drain];
}



- (void)mergeChanges:(NSNotification *)notification
{
    NSManagedObjectContext *mainContext = [JSKDataMiner sharedInstance].mainObjectContext;
    
    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];
}




@end
