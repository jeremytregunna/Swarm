//
//  DPSMessageTests.m
//  SwarmTests
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSMessageTests.h"
#import "SwarmMessage.h"

@interface SwarmMessage (PrivateMethods)
@property (nonatomic, readwrite, strong) NSUUID* messageID;
@property (nonatomic, readwrite, strong) NSDate* date;
@end

@implementation DPSMessageTests
{
    NSDictionary* sample;
}

- (void)setUp
{
    [super setUp];

    sample = @{
        @"messageID": [[NSUUID alloc] initWithUUIDString:@"68753A44-4D6F-1226-9C60-0050E4C00067"],
        @"purpose": @(DPSMessagePurposePayload),
        @"sender": @(1),
        @"receiver": @(2),
        @"forwardedBy": @(0),
        @"date": [NSDate dateWithTimeIntervalSince1970:344533500],
        @"payload": @{ @"test": @"data" }
    };
}

- (SwarmMessage*)messageFromSample
{
    SwarmMessage* msg = [SwarmMessage messageWithPurpose:[sample[@"purpose"] charValue] from:[sample[@"sender"] unsignedIntValue] to:[sample[@"receiver"] unsignedIntValue] withPayload:sample[@"payload"]];
    msg.messageID = sample[@"messageID"];
    msg.date = sample[@"date"];
    return msg;
}

- (void)testMessageFromSampleDictionary
{
    SwarmMessage* msg = [SwarmMessage messageWithDictionary:sample];
    STAssertNotNil(msg, @"DPSMessage must not be nil");
    STAssertEqualObjects(msg.messageID, sample[@"messageID"], @"Message ID match");
    STAssertEquals(msg.purpose, [sample[@"purpose"] charValue], @"Message purpose match");
    STAssertEquals(msg.sender, [sample[@"sender"] unsignedIntValue], @"Message sender match");
    STAssertEquals(msg.receiver, [sample[@"receiver"] unsignedIntValue], @"Message receiver match");
    STAssertEqualObjects(msg.payload, sample[@"payload"], @"Message payload match");
}

- (void)testMessageID
{
    SwarmMessage* msg = [self messageFromSample];
    STAssertEqualObjects(msg.messageID, sample[@"messageID"], @"Message ID differs");
}

- (void)testPurpose
{
    SwarmMessage* msg = [self messageFromSample];
    STAssertEquals(msg.purpose, [sample[@"purpose"] charValue], @"Purpose differs");
}

- (void)testSender
{
    SwarmMessage* msg = [self messageFromSample];
    STAssertEquals(msg.sender, [sample[@"sender"] unsignedIntValue], @"Sender differs");
}

- (void)testReceiver
{
    SwarmMessage* msg = [self messageFromSample];
    STAssertEquals(msg.receiver, [sample[@"receiver"] unsignedIntValue], @"Receiver differs");
}

- (void)testDate
{
    SwarmMessage* msg = [self messageFromSample];
    STAssertEquals([msg.date timeIntervalSince1970], [sample[@"date"] timeIntervalSince1970], @"Date differs");
}

- (void)testPayload
{
    SwarmMessage* msg = [self messageFromSample];
    STAssertEqualObjects(msg.payload, sample[@"payload"], @"Payload differs");
}

- (void)testDictionaryFromFields
{
    SwarmMessage* msg = [self messageFromSample];
    NSDictionary* fields = [msg dictionaryFromFields];

    STAssertEqualObjects(fields, sample, @"Fields differ");
}

@end
