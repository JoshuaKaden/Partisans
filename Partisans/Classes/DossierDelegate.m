//
//  DossierDelegate.m
//  Partisans
//
//  Created by Joshua Kaden on 7/22/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "DossierDelegate.h"
#import "PlayerEnvoy.h"

@implementation DossierDelegate

@synthesize playerEnvoy = m_playerEnvoy;

- (void)dealloc
{
    [m_playerEnvoy release];
    [super dealloc];
}

- (id)initWithPlayerEnvoy:(PlayerEnvoy *)playerEnvoy
{
    self = [super init];
    if (self)
    {
        self.playerEnvoy = playerEnvoy;
    }
    return self;
}

- (PlayerEnvoy *)supplyPlayerEnvoy:(DossierViewController *)dossierViewController
{
    return self.playerEnvoy;
}

@end
