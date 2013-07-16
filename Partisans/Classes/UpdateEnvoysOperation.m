//
//  UpdateEnvoysOperation.m
//  Partisans
//
//  Created by Joshua Kaden on 7/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "UpdateEnvoysOperation.h"

#import "GameEnvoy.h"
#import "GamePrecis.h"
#import "JSKDataMiner.h"
#import "SystemMessage.h"

#import <CoreData/CoreData.h>


@interface UpdateEnvoysOperation ()

@property (nonatomic, strong) NSArray *envoys;

- (void)mergeChanges:(NSNotification *)notification;

@end



@implementation UpdateEnvoysOperation


@synthesize envoys = m_envoys;


- (void)dealloc
{
    [m_envoys release];
    [super dealloc];
}


- (id)initWithEnvoys:(NSArray *)envoys
{
    self = [super init];
    if (self)
    {
        self.envoys = envoys;
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
    
    // Save the envoys.
    for (NSObject *envoy in self.envoys)
    {
        if ([envoy isKindOfClass:[GamePrecis class]])
        {
            GamePrecis *precis = (GamePrecis *)envoy;
            GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
            // Sanity check: Do the game IDs match?
            if (![precis.intramuralID isEqualToString:gameEnvoy.intramuralID])
            {
                break;
            }
            gameEnvoy.modifiedDate = precis.modifiedDate;
            [gameEnvoy commitModifiedDate];
        }
        else
        {
            [envoy performSelector:@selector(commitInContext:) withObject:context];
        }
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
