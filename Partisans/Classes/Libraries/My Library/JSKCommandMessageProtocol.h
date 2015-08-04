//
//  JSKCommandMessageProtocol.h
//  Partisans
//
//  Created by Joshua Kaden on 8/3/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSKCommandMessageProtocol <NSObject>
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *responseKey;
@end
