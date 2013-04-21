//
//  DPSHistoryItemTests.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-08.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSHistoryItemTests.h"
#import "SwarmHistoryItem.h"

@implementation DPSHistoryItemTests
{
    NSUUID* uuid;
    SwarmHistoryItem* historyItem;
    NSTimeInterval currentTimestamp;
}

- (void)setUp
{
    [super setUp];

    uuid = [[NSUUID alloc] initWithUUIDString:@"68753A44-4D6F-1226-9C60-0050E4C00067"];
    historyItem = [SwarmHistoryItem historyItemWithMessageID:uuid];
    currentTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)testCreate
{
    STAssertNotNil(historyItem, @"Valid instance");
}

- (void)testUUID
{
    STAssertEqualObjects(historyItem.messageID, uuid, @"Message UUID equality");
}

- (void)testDateNil
{
    STAssertFalse(historyItem.sent, @"Not sent");
    STAssertNil(historyItem.sentDate, @"Sent date nil");
}

- (void)testSetSent
{
    historyItem.sent = YES;
    STAssertTrue(historyItem.sent, @"Sent");
    STAssertEqualsWithAccuracy([historyItem.sentDate timeIntervalSince1970], currentTimestamp, 1.0, @"Sent Date correct");
}

@end
