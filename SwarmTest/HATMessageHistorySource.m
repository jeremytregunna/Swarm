//
//  HATMessageHistorySource.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-20.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "HATMessageHistorySource.h"
#import "DPSMessage.h"
#import "DPSHistoryItem.h"

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

- (void)storeHistoryItem:(DPSHistoryItem*)historyItem
{
    [_history addObject:historyItem];
}

- (DPSHistoryItem*)historyItemForMessageID:(NSUUID*)messageID
{
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(DPSHistoryItem* historyItem, NSDictionary* bindings) {
        return [historyItem.messageID isEqual:messageID];
    }];
    NSArray* filteredArray = [_history filteredArrayUsingPredicate:predicate];
    return [filteredArray lastObject];
}

@end
