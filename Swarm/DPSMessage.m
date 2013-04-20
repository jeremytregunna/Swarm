//
//  DPSMessage.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSMessage.h"

@interface DPSMessage ()
@property (nonatomic, readwrite, strong) NSUUID* messageID;
@property (nonatomic, readwrite, strong) NSDate* date;

- (instancetype)initWithPurpose:(DPSMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload;
@end

@implementation DPSMessage

+ (instancetype)messageWithPurpose:(DPSMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload
{
    return [[self alloc] initWithPurpose:purpose from:sender to:receiver withPayload:payload];
}

+ (instancetype)messageWithDictionary:(NSDictionary*)dictionary
{
    DPSMessagePurpose purpose = [dictionary[@"purpose"] charValue];
    uint32_t sender = [dictionary[@"sender"] unsignedIntValue];
    uint32_t receiver = [dictionary[@"receiver"] unsignedIntValue];
    NSDictionary* payload = dictionary[@"payload"];
    DPSMessage* msg = [[self alloc] initWithPurpose:purpose from:sender to:receiver withPayload:payload];
    msg->_messageID = dictionary[@"messageID"];

    return msg;
}

- (instancetype)initWithPurpose:(DPSMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload
{
    if((self = [super init]))
    {
        _messageID = [NSUUID UUID];
        _purpose = purpose;
        _sender = sender;
        _forwardedBy = 0;
        _receiver = receiver;
        _date = [NSDate date];
        _payload = [payload copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    typeof(self) result = [[[self class] alloc] initWithPurpose:_purpose from:_sender to:_receiver withPayload:_payload];
    result.messageID = self.messageID;
    result.forwardedBy = self.forwardedBy;
    result.date = self.date;
    return result;
}

- (BOOL)isEqual:(DPSMessage*)other
{
    return [_messageID isEqual:other.messageID] && _purpose == other.purpose && _sender == other.sender && _receiver == other.sender && [_date isEqualToDate:other.date] && [_payload isEqualToDictionary:other.payload];
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [_messageID hash];
    result = prime * result + _purpose;
    result = prime * result + _sender;
    result = prime * result + _receiver;
    result = prime * result + [_date hash];
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
        @"forwardedBy",
        @"date",
        @"payload"
    ];
    return [self dictionaryWithValuesForKeys:keys];
}

@end
