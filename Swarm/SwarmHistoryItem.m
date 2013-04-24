//
//  SwarmHistoryItem.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "SwarmHistoryItem.h"

@interface SwarmHistoryItem ()
- (instancetype)initWithMessageID:(NSUUID*)messageID;
@end

@implementation SwarmHistoryItem

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (instancetype)historyItemWithMessageID:(NSUUID*)messageID
{
    return [[self alloc] initWithMessageID:messageID];
}

- (instancetype)initWithMessageID:(NSUUID*)messageID
{
    if((self = [super init]))
    {
        _messageID = messageID;
        _sent = NO;
    }
    return self;
}

#pragma mark - Secure Coding

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if((self = [super init]))
    {
        _messageID = [aDecoder decodeObjectOfClass:[NSUUID class] forKey:@"messageID"];
        _sent = [aDecoder decodeBoolForKey:@"sent"];
        _sentDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"sentDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_messageID forKey:@"messageID"];
    [aCoder encodeBool:_sent forKey:@"sent"];
    [aCoder encodeObject:_sentDate forKey:@"sentDate"];
}

#pragma mark - Accessors

- (void)setSent:(BOOL)sent
{
    [self willChangeValueForKey:@"sent"];
    _sent = sent;
    _sentDate = [NSDate date];
    [self didChangeValueForKey:@"sent"];
}

@end
