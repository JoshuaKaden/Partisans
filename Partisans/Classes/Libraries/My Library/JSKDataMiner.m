//
//  JSKDataMiner.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKDataMiner.h"
#import "JSKSystemMessage.h"

NSString * const JSKDataMinerDidSaveNotification = @"JSKDataMinerDidSaveNotification";
NSString * const JSKDataMinerDidSaveFailedNotification = @"JSKDataMinerDidSaveFailedNotification";


@interface JSKDataMiner ()

@property (atomic, strong) NSDictionary *importedIDsMap;

- (void)prepareDatabaseFolder;
//- (void)moveOldDataToNewFolder;
- (NSURL *)databaseURL;
- (NSURL *)applicationDocumentsDirectory;

@end


@implementation JSKDataMiner

@synthesize managedObjectModel = m_managedObjectModel;
@synthesize mainObjectContext = m_mainObjectContext;
@synthesize persistentStoreCoordinator = m_persistentStoreCoordinator;
@synthesize importedIDsMap = m_importedIDsMap;

static NSString * const kDataManagerModelName = @"Partisans";
static NSString * const kDataManagerSQLiteName = @"Partisans.sqlite";
static NSString * const kDataManagerSQLiteBaseName = @"Partisans";


+ (JSKDataMiner *)sharedInstance {
    
	static dispatch_once_t pred;
	static JSKDataMiner *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}


- (void)dealloc {
    
    [m_managedObjectModel release];
    [m_mainObjectContext release];
    [m_persistentStoreCoordinator release];
    [m_importedIDsMap release];
    [super dealloc];
}



+ (NSManagedObjectContext *)mainObjectContext {
    
    return [self sharedInstance].mainObjectContext;
}



- (NSManagedObjectContext *)mainObjectContext {
    
	if (m_mainObjectContext)
		return m_mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return m_mainObjectContext;
	}
    
	m_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[m_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return m_mainObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    
	if (m_managedObjectModel)
		return m_managedObjectModel;
    
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
	m_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return m_managedObjectModel;
}



- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
	if (m_persistentStoreCoordinator)
		return m_persistentStoreCoordinator;
    
    
    [self prepareDatabaseFolder];
    
    
	// Get the path to the SQLite file.
    NSURL *storeURL = [[self databaseURL] URLByAppendingPathComponent:kDataManagerSQLiteName];
    //    NSURL *storeURL = [self applicationDocumentsDirectory] URLByAppendingPathComponent:kDataManagerSQLiteName];
    //	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
    //	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	m_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	if (![m_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:storeURL
                                                          options:options
                                                            error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return m_persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





- (NSURL *)databaseURL {
    
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
    NSURL *theURL = [NSURL fileURLWithPath:databasePath isDirectory:YES];
    
    //    debugLog(@"original string: %@", databasePath);
    //    debugLog(@"url desc: %@", theURL.description);
    //    debugLog(@"url debug desc: %@", theURL.debugDescription);
    //    debugLog(@"url absoluteString: %@", theURL.absoluteString);
    //    debugLog(@"url path: %@", theURL.path);
    //    debugLog(@"url relativePath: %@", theURL.relativePath);
    //    debugLog(@"url relativeString: %@", theURL.relativeString);
    
    return theURL;
}


//- (void)moveOldDataToNewFolder {
//
//    NSURL *fullDbURL = [[self databaseURL] URLByAppendingPathComponent:kDataManagerSQLiteName];
//    NSFileManager *manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:fullDbURL.path]) {
//
//        NSURL *oldURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDataManagerSQLiteName];
//        if ([manager fileExistsAtPath:oldURL.path]) {
//
//            NSError *error = nil;
//            [manager moveItemAtURL:oldURL toURL:fullDbURL error:&error];
//
//            if (error) {
//                debugLog(@"Error moving existing data: %@", [error localizedDescription]);
//
//                // This is nasty enough to warrant an exception.
//                [NSException raise:@"Copy Old Data Error" format:@"Unable to upgrade your existing data because of an error when copying from %@ to %@", oldURL.path, fullDbURL.path];
//
//                return;
//            }
//        }
//    }
//}


- (void)prepareDatabaseFolder {
    
    NSString *databasePath = [self.databaseURL path];
    
	// Ensure the database directory exists.
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:databasePath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:databasePath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error) {
			debugLog(@"Error creating directory path: %@", [error localizedDescription]);
            return;
        }
	}
    
    
    //    [self moveOldDataToNewFolder];
}



- (NSManagedObjectContext *)newManagedObjectContext {
    
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	return ctx;
}


- (void)reset {
    
    m_managedObjectModel = nil;
    m_mainObjectContext = nil;
    m_persistentStoreCoordinator = nil;
}


- (BOOL)save {
    
	return [self saveWithContext:self.mainObjectContext];
}

+ (BOOL)save
{
    JSKDataMiner *sharedInstance = [self sharedInstance];
    return [sharedInstance save];
}


- (BOOL)saveWithContext:(NSManagedObjectContext *)theContext {
    
	if (![theContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![theContext save:&error]) {
		NSLog(@"Error while saving: %@  --  %@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:JSKDataMinerDidSaveFailedNotification
                                                            object:error];
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:JSKDataMinerDidSaveNotification object:nil];
	return YES;
}



#pragma mark - Imported to Local ID map

+ (NSManagedObjectID *)localObjectIDForImported:(NSString *)importedObjectString {
    
    NSManagedObjectID *managedObjectID = nil;
    
    // Check the stashed map.
    NSDictionary *importedIDsMap = [self sharedInstance].importedIDsMap;
    if (importedIDsMap) {
        
        managedObjectID = [importedIDsMap valueForKey:importedObjectString];
        if (managedObjectID) {
            return managedObjectID;
        }
    }
    
    NSURL *objectIDURL = [NSURL URLWithString:importedObjectString];
    NSPersistentStoreCoordinator *store = [self sharedInstance].persistentStoreCoordinator;
    managedObjectID = [store managedObjectIDForURIRepresentation:objectIDURL];
    return managedObjectID;
}


+ (void)mapLocalObjectID:(NSManagedObjectID *)localObjectID toImported:(NSString *)importedObjectString {
    
    NSDictionary *importedIDsMap = [self sharedInstance].importedIDsMap;
    
    if (!importedIDsMap) {
        
        // Create the stashed map.
        [self sharedInstance].importedIDsMap = [NSDictionary dictionaryWithObject:localObjectID forKey:importedObjectString];
        return;
    }
    
    
    if ([importedIDsMap valueForKey:importedObjectString]) {
        return;
    }
    
    
    NSMutableDictionary *mapList = [[NSMutableDictionary alloc] initWithDictionary:importedIDsMap];
    
    [mapList setValue:localObjectID forKey:importedObjectString];
    
    [self sharedInstance].importedIDsMap = [NSDictionary dictionaryWithDictionary:mapList];
    [mapList release];
}


+ (void)clearLocalIDCache {
    
    [self sharedInstance].importedIDsMap = nil;
}



@end
