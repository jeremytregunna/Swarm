//
//  JMessage.m
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "JMessage.h"

@interface JMessage ()
@property (nonatomic, readwrite, strong) NSUUID* messageID;

- (instancetype)initWithPurpose:(JMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload;
@end

@implementation JMessage

+ (instancetype)messageWithPurpose:(JMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload
{
    return [[self alloc] initWithPurpose:purpose from:sender to:receiver withPayload:payload];
}

- (instancetype)initWithPurpose:(JMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload
{
    if((self = [super init]))
    {
        _messageID = [NSUUID UUID];
        _purpose = purpose;
        _sender = sender;
        _receiver = receiver;
        _payload = [payload copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    typeof(self) result = [[[self class] alloc] initWithPurpose:_purpose from:_sender to:_receiver withPayload:_payload];
    result.messageID = self.messageID;
    return result;
}

- (BOOL)isEqual:(JMessage*)other
{
    return [_messageID isEqual:other.messageID] && _purpose == other.purpose && _sender == other.sender && _receiver == other.sender && [_payload isEqualToDictionary:other.payload];
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [_messageID hash];
    result = prime * result + _purpose;
    result = prime * result + _sender;
    result = prime * result + _receiver;
    result = prime * result + [_payload hash];

    return result;
}

#pragma mark - Messageable

- (NSDictionary*)dictionaryFromFields
{
    NSArray* keys = @[
        @"messageID",
        @"purpose",
        @"sender",
        @"receiver",
        @"payload"
    ];
    return [self dictionaryWithValuesForKeys:keys];
}

@end
