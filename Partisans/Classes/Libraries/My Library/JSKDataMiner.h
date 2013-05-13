//
//  JSKDataMiner.h
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const JSKDataMinerDidSaveNotification;
extern NSString * const JSKDataMinerDidSaveFailedNotification;


@interface JSKDataMiner : NSObject

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (JSKDataMiner *)sharedInstance;

+ (NSManagedObjectContext *)mainObjectContext;

+ (NSManagedObjectID *)localObjectIDForImported:(NSString *)importedObjectString;
+ (void)mapLocalObjectID:(NSManagedObjectID *)localObjectID toImported:(NSString *)importedObjectString;
+ (void)clearLocalIDCache;

- (NSManagedObjectContext *)newManagedObjectContext;
- (void)reset;
//- (NSString*)sharedDocumentsPath;
- (void)prepareDatabaseFolder;

- (BOOL)save;
- (BOOL)saveWithContext:(NSManagedObjectContext *)theContext;

+ (BOOL)save;

@end
