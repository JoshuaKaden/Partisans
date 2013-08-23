//
//  JSKSystemMessage.h
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
