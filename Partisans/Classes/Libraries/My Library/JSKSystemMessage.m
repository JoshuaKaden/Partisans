//
//  JSKSystemMessage.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
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

#import "JSKSystemMessage.h"

#import "Reachability.h"
#import <CoreBluetooth/CoreBluetooth.h>


NSString * const JSKSymbolCheck = @"✓";
NSString * const JSKSymbolX     = @"✗";
NSString * const JSKSymbolUp    = @"▲";
NSString * const JSKSymbolDown  = @"▼";


@interface JSKSystemMessage ()

@property (nonatomic, strong) NSOperationQueue *queue;

- (NSURL *)applicationDocumentsDirectory;
- (void)createDataFileSharingDirectory;

@end



@implementation JSKSystemMessage


@synthesize queue = m_queue;
@synthesize dataFileSharingDirectoryURL = m_dataFileSharingDirectory;
@synthesize myPeerID = m_myPeerID;


- (void)dealloc {
    
    [m_queue release];
    [m_dataFileSharingDirectory release];
    [m_myPeerID release];
    
    [super dealloc];
}


+ (JSKSystemMessage *)sharedInstance {
    
	static dispatch_once_t pred;
	static JSKSystemMessage *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}


- (id)init {
	if ((self = [super init]))
	{
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setName:@"com.chadfordsoftware.questPlayerQueue"];
        [queue setMaxConcurrentOperationCount:1];
        self.queue = queue;
        [queue release];
        
        // This is the place where we'll put export files and look for import files if we're using iTunes File Sharing.
        self.dataFileSharingDirectoryURL = [self applicationDocumentsDirectory];
        //        NSString *directoryName = NSLocalizedString(@"Seventh Tradition Data", @"Seventh Tradition Data  --  directory name");
        //        self.dataFileSharingDirectoryURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:directoryName isDirectory:YES];
        //        [self createDataFileSharingDirectory];
	}
	return self;
}



// Overriding the accessor here.
- (NSString *)myPeerID
{
    NSString *myPeerID = m_myPeerID;
    if (myPeerID)
    {
        return myPeerID;
    }
    
    // Check user defaults for the peer ID.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    myPeerID = [userDefaults objectForKey:@"myPeerID"];
    
    return myPeerID;
}



- (void)createDataFileSharingDirectory {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *path = self.dataFileSharingDirectoryURL.path;
    
    
    if ([manager fileExistsAtPath:path]) {
        return;
    }
    
    
    NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                     forKey:NSFileProtectionKey];
    NSError *error = nil;
    [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attr error:&error];
    if (error) {
        debugLog(@"Error creating directory path: %@", [error localizedDescription]);
        return;
    }
}



- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



+ (BOOL)isOnline
{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}


+ (BOOL)isWiFiAvailable
{
    Reachability *r = [Reachability reachabilityForLocalWiFi];
    NetworkStatus status = [r currentReachabilityStatus];
    if (status == NotReachable)
    {
        return NO;
    }
    return YES;
}


+ (BOOL)isPad {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}



+ (UIInterfaceOrientation)deviceOrientation {
    
    // Thanks to Damien Deville for this technique.
    // http://ddeville.me/2011/01/getting-the-interface-orientation-in-ios/
    
    return [[UIApplication sharedApplication] statusBarOrientation];
}


+ (NSOperationQueue *)mainQueue {
    
    return [self sharedInstance].queue;
}

+ (NSString *)myPeerID
{
    return [self sharedInstance].myPeerID;
}


+ (NSURL *)dataFileSharingDirectoryURL {
    
    return [self sharedInstance].dataFileSharingDirectoryURL;
}


+ (UIColor *)extraLightGrayColor {
    
    return [UIColor colorWithRed:0.79f green:0.79f blue:0.79f alpha:1.0f];
}


+ (UIColor *)extraDarkGrayColor {
    
    return [UIColor colorWithRed:0.20f green:0.20f blue:0.20f alpha:1.0f];
}

+ (UIColor *)nearlyBlackColor {
    
    return [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f];
}


@end
