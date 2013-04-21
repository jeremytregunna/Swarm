//
//  SwarmMessage.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, SwarmMessagePurpose)
{
    SwarmMessagePurposeNone = 0,
    SwarmMessagePurposeHeartbeat,
    SwarmMessagePurposePayload,
    SwarmMessagePurposeReplay,
};

@protocol SwarmMessageable <NSObject>
- (NSDictionary*)dictionaryFromFields;
@end

@interface SwarmMessage : NSObject <NSCopying, SwarmMessageable>
@property (nonatomic, readonly, strong) NSUUID* messageID;
@property (nonatomic, readonly) SwarmMessagePurpose purpose;
@property (nonatomic, readonly) uint32_t sender, receiver;
@property (nonatomic) uint32_t forwardedBy;
@property (nonatomic, readonly, strong) NSDate* date;
@property (nonatomic, readonly, copy) NSDictionary* payload;

+ (instancetype)messageWithPurpose:(SwarmMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload;
+ (instancetype)messageWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)dictionaryFromFields;
@end
