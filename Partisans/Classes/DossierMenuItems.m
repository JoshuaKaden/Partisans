//
//  DossierMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "DossierMenuItems.h"

#import "PlayerEnvoy.h"

@implementation DossierMenuItems

@synthesize playerEnvoy = m_playerEnvoy;

- (void)dealloc
{
    [m_playerEnvoy release];
    [super dealloc];
}

@end
