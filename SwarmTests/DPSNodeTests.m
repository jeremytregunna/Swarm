//
//  DPSNodeTests.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-08.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSNodeTests.h"
#import "SwarmNode.h"
#import "SwarmHistoryItem.h"

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

@interface SwarmNode (PrivateMethods)
@property (nonatomic, strong) GCDAsyncSocket* listenSocket;
@end

@implementation DPSNodeTests
{
    SwarmNode* rootNode;
    HistoryWriter* historyWriter;
}

- (void)setUp
{
    [super setUp];

    historyWriter = [[HistoryWriter alloc] init];
    rootNode = [SwarmNode nodeWithID:1 historyDataSource:historyWriter];
}

- (void)testRootExists
{
    STAssertNotNil(rootNode, @"Root node must not be nil");
}

@end
