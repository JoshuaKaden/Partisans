//
//  DecisionMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"


typedef enum
{
    DecisionMenuSectionStatus,
    DecisionMenuSectionVotes,
    DecisionMenuSection_MaxValue
} DecisionMenuSection;

typedef enum
{
    DecisionMenuVotesRowTotal,
    DecisionMenuVotesRowYea,
    DecisionMenuVotesRowNay,
    DecisionMenuVotesRow_MaxValue
} DecisionMenuVotesRow;


@interface DecisionMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
