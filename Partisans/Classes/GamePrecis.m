//
//  GamePrecis.m
//  Partisans
//
//  Created by Joshua Kaden on 7/16/13.
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

#import "GamePrecis.h"
#import "GameEnvoy.h"

@implementation GamePrecis

@synthesize intramuralID = m_intramuralID;
@synthesize modifiedDate = m_modifedDate;

- (void)dealloc
{
    [m_intramuralID release];
    [m_modifedDate release];
    [super dealloc];
}

- (id)initWithEnvoy:(GameEnvoy *)envoy
{
    self = [super init];
    if (self)
    {
        self.intramuralID = envoy.intramuralID;
        self.modifiedDate = envoy.modifiedDate;
    }
    return self;
}

- (NSString *)description
{
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"GamePrecis", @"Class",
                              self.intramuralID, @"intramuralID",
                              self.modifiedDate.description, @"modifiedDate", nil];
    return descDict.description;
}


#pragma mark - NSCoder methods

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    [aCoder encodeObject:self.modifiedDate forKey:@"modifiedDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        self.modifiedDate = [aDecoder decodeObjectForKey:@"modifiedDate"];
    }
    return self;
}

@end
