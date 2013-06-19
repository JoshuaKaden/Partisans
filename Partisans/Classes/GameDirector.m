//
//  GameDirector.m
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameDirector.h"

#import "GameEnvoy.h"
#import "JSKCommandParcel.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"
#import "UpdateGameOperation.h"


@interface GameDirector ()

@end


@implementation GameDirector

- (void)dealloc
{
    [super dealloc];
}

- (GameEnvoy *)gameEnvoy
{
    return [SystemMessage gameEnvoy];
}

- (void)startGame
{
    GameEnvoy *gameEnvoy = [self gameEnvoy];
    
    
    
    gameEnvoy.startDate = [NSDate date];
    
    [gameEnvoy commitAndSave];
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:[SystemMessage playerEnvoy].peerID object:gameEnvoy];
    [SystemMessage sendParcelToPlayers:parcel];
    [parcel release];
}

@end
