//
//  CreateGameOperation.m
//  Partisans
//
//  Created by Joshua Kaden on 5/18/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "CreateGameOperation.h"

#import "JSKDataMiner.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"

#import <CoreData/CoreData.h>


@interface CreateGameOperation ()

- (void)mergeChanges:(NSNotification *)notification;

@end



@implementation CreateGameOperation


@synthesize envoy = m_envoy;


- (void)dealloc
{
    [m_envoy release];
    [super dealloc];
}


- (id)initWithEnvoy:(GameEnvoy *)envoy
{
    self = [super init];
    if (self) {
        self.envoy = envoy;
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
    
    if ([self.envoy respondsToSelector:@selector(commitInContext:)]) {
        [self.envoy performSelector:@selector(commitInContext:) withObject:context];
    }
    
    
    
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
