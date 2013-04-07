//
//  DPSHistoryItem.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSHistoryItem.h"

@interface DPSHistoryItem ()
- (instancetype)initWithMessageID:(NSUUID*)messageID;
@end

@implementation DPSHistoryItem

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

#pragma mark - Accessors

- (void)setSent:(BOOL)sent
{
    [self willChangeValueForKey:@"sent"];
    _sent = sent;
    _sentDate = [NSDate date];
    [self didChangeValueForKey:@"sent"];
}

@end
