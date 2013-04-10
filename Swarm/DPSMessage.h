//
//  DPSMessage.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, DPSMessagePurpose)
{
    DPSMessagePurposeNone = 0,
    DPSMessagePurposeHeartbeat,
    DPSMessagePurposePayload,
};

@protocol DPSMessageable <NSObject>
- (NSDictionary*)dictionaryFromFields;
@end

@interface DPSMessage : NSObject <NSCopying, DPSMessageable>
@property (nonatomic, readonly, strong) NSUUID* messageID;
@property (nonatomic, readonly) DPSMessagePurpose purpose;
@property (nonatomic, readonly) uint32_t sender, receiver;
@property (nonatomic, readonly, copy) NSDictionary* payload;

+ (instancetype)messageWithPurpose:(DPSMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload;
- (NSDictionary*)dictionaryFromFields;
@end
