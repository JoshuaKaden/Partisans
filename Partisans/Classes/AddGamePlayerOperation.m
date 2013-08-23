//
//  AddGamePlayerOperation.m
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
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
