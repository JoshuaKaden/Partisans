//
//  JSKSystemMessage.h
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const JSKSymbolCheck;
extern NSString * const JSKSymbolX;
extern NSString * const JSKSymbolUp;
extern NSString * const JSKSymbolDown;


// debug status -- modifies NSLog output to be conditional on this flag
// if the flag set to 0, there will be no debug output
#define DEBUGFLAG 1;

#ifdef DEBUGFLAG
#   define debugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define debugLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define alwaysLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);



@interface JSKSystemMessage : NSObject


@property (nonatomic, strong) NSString *myPeerID;
@property (nonatomic, strong) NSURL *dataFileSharingDirectoryURL;


/** Use this method to access the singleton. */
+ (JSKSystemMessage *)sharedInstance;

/** These are convenience methods to quickly read the singleton's properties.
 */
+ (UIInterfaceOrientation)deviceOrientation;
+ (BOOL)isPad;
+ (NSOperationQueue *)mainQueue;
+ (NSString *)myPeerID;
+ (NSURL *)dataFileSharingDirectoryURL;

+ (UIColor *)extraLightGrayColor;
+ (UIColor *)extraDarkGrayColor;
+ (UIColor *)nearlyBlackColor;

+ (BOOL)isOnline;
+ (BOOL)isWiFiAvailable;

@end
