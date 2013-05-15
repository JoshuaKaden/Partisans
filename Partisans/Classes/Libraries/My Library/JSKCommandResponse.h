//
//  JSKCommandResponse.h
//  Partisans
//
//  Created by Joshua Kaden on 5/10/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKCommandMessage.h"

typedef enum
{
    JSKCommandResponseTypeAcknowledge,
    JSKCommandResponseType_maxValue
} JSKCommandResponseType;

@interface JSKCommandResponse : NSObject <NSCoding>

@property (nonatomic, assign)   JSKCommandResponseType commandResponseType;
@property (nonatomic, assign)   JSKCommandMessageType respondingToType;
@property (readonly, nonatomic) NSString *commandResponseTypeName;
@property (nonatomic, strong)   NSString *to;
@property (nonatomic, strong)   NSString *from;
@property (nonatomic, strong)   NSObject <NSCoding> *object;

- (id)initWithType:(JSKCommandResponseType)commandResponseType
                to:(NSString *)to
              from:(NSString *)from
      respondingTo:(JSKCommandMessageType)respondingTo;

+ (NSString *)responseTypeName:(JSKCommandResponseType)responseType;

@end
