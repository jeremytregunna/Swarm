//
//  main.m
//  swarmd
//
//  Created by Jeremy Tregunna on 2013-04-09.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Swarm.h"

@interface DPSHistoryWriter : NSObject <DPSNodeHistoryDataSource>
@end
@implementation DPSHistoryWriter
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

int main(int argc, const char* argv[])
{
    @autoreleasepool {
        DPSHistoryWriter* historyWriter = [[DPSHistoryWriter alloc] init];
        DPSNode* root = [DPSNode nodeWithID:1 historyDataSource:historyWriter];
        [root listen];
    }
    return 0;
}

