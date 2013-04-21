//
//  HATMessageHistorySource.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-20.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "HATMessageHistorySource.h"
#import "SwarmMessage.h"
#import "SwarmHistoryItem.h"

@implementation HATMessageHistorySource
{
    NSMutableArray* _history;
}

- (id)init
{
    self = [super init];
    _history = [NSMutableArray array];
    return self;
}

- (void)storeHistoryItem:(SwarmHistoryItem*)historyItem
{
    [_history addObject:historyItem];
}

- (SwarmHistoryItem*)historyItemForMessageID:(NSUUID*)messageID
{
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(SwarmHistoryItem* historyItem, NSDictionary* bindings) {
        return [historyItem.messageID isEqual:messageID];
    }];
    NSArray* filteredArray = [_history filteredArrayUsingPredicate:predicate];
    return [filteredArray lastObject];
}

@end
