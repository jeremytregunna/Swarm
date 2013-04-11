//
//  main.m
//  swarmd
//
//  Created by Jeremy Tregunna on 2013-04-09.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Swarm.h"
#import "Criteria.h"

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
        __block NSMutableArray* hosts = [NSMutableArray array];
        [Criteria addOption:@[@"c", @"connect"] callback:^(NSString* value) {
            if([value rangeOfString:@"."].location != NSNotFound) // Really bad validation
                [hosts addObject:value];
        }];
        [Criteria run];

        DPSHistoryWriter* historyWriter = [[DPSHistoryWriter alloc] init];
        DPSNode* root = [DPSNode nodeWithID:1 historyDataSource:historyWriter];
        [root listen];

        [root connectToNodes:hosts];

        while(root.running)
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return 0;
}

