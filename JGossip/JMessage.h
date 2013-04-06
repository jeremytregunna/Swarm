//
//  JMessage.h
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, JMessagePurpose)
{
    JMessagePurposeInvalid = 0,
    JMessagePurposeHeartbeat,
    JMessagePurposePayload,
    JMessagePurposeForward,
};

@protocol JMessageable <NSObject>
- (NSDictionary*)dictionaryFromFields;
@end

@interface JMessage : NSObject <NSCopying, JMessageable>
@property (nonatomic, readonly) JMessagePurpose purpose;
@property (nonatomic, readonly) uint32_t sender, receiver;
@property (nonatomic, readonly, copy) NSDictionary* payload;

+ (instancetype)messageWithPurpose:(JMessagePurpose)purpose from:(uint32_t)sender to:(uint32_t)receiver withPayload:(NSDictionary*)payload;
- (NSDictionary*)dictionaryFromFields;
@end
