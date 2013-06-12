//
//  JSKCommandParcel.h
//  Partisans
//
//  Created by Joshua Kaden on 5/10/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    JSKCommandParcelTypeDigest,
    JSKCommandParcelTypeModifiedDate,
    JSKCommandParcelTypeResponse,
    JSKCommandParcelTypeUnknown,
    JSKCommandParcelTypeUpdate,
    JSKCommandParcelType_maxValue
} JSKCommandParcelType;


@interface JSKCommandParcel : NSObject <NSCoding>

@property (nonatomic, assign)   JSKCommandParcelType commandParcelType;
@property (nonatomic, strong)   NSString *responseKey;
@property (readonly, nonatomic) NSString *commandParcelTypeName;
@property (nonatomic, strong)   NSString *to;
@property (nonatomic, strong)   NSString *from;
@property (nonatomic, strong)   NSObject <NSCoding> *object;

- (id)initWithType:(JSKCommandParcelType)commandParcelType
                to:(NSString *)to
              from:(NSString *)from
            object:(id<NSCoding>)object;

- (id)initWithType:(JSKCommandParcelType)commandParcelType
                to:(NSString *)to
              from:(NSString *)from
            object:(id<NSCoding>)object
       responseKey:(NSString *)responseKey;

+ (NSString *)responseTypeName:(JSKCommandParcelType)responseType;

@end
