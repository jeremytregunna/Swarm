//
//  DPSNodeTests.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-08.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSNodeTests.h"
#import "DPSNode.h"
#import "DPSHistoryItem.h"

@interface HistoryWriter : NSObject <DPSNodeHistoryDataSource>
@end
@implementation HistoryWriter
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

@interface DPSNode (PrivateMethods)
@property (nonatomic, strong) GCDAsyncSocket* listenSocket;
@end

@implementation DPSNodeTests
{
    DPSNode* rootNode;
    HistoryWriter* historyWriter;
}

- (void)setUp
{
    [super setUp];

    historyWriter = [[HistoryWriter alloc] init];
    rootNode = [DPSNode nodeWithID:1 historyDataSource:historyWriter];
}

- (void)testRootExists
{
    STAssertNotNil(rootNode, @"Root node must not be nil");
}

@end
