//
//  DPSMessageTests.m
//  SwarmTests
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSMessageTests.h"
#import "DPSMessage.h"

@interface DPSMessage (PrivateMethods)
@property (nonatomic, readwrite, strong) NSUUID* messageID;
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
        @"payload": @{ @"test": @"data" }
    };
}

- (DPSMessage*)messageFromSample
{
    DPSMessage* msg = [DPSMessage messageWithPurpose:[sample[@"purpose"] charValue] from:[sample[@"sender"] unsignedIntValue] to:[sample[@"receiver"] unsignedIntValue] withPayload:sample[@"payload"]];
    msg.messageID = sample[@"messageID"];
    return msg;
}

- (void)testMessageFromSampleDictionary
{
    DPSMessage* msg = [DPSMessage messageWithDictionary:sample];
    STAssertNotNil(msg, @"DPSMessage must not be nil");
    STAssertEqualObjects(msg.messageID, sample[@"messageID"], @"Message ID match");
    STAssertEquals(msg.purpose, [sample[@"purpose"] charValue], @"Message purpose match");
    STAssertEquals(msg.sender, [sample[@"sender"] unsignedIntValue], @"Message sender match");
    STAssertEquals(msg.receiver, [sample[@"receiver"] unsignedIntValue], @"Message receiver match");
    STAssertEqualObjects(msg.payload, sample[@"payload"], @"Message payload match");
}

- (void)testMessageID
{
    DPSMessage* msg = [self messageFromSample];
    STAssertEqualObjects(msg.messageID, sample[@"messageID"], @"Message ID differs");
}

- (void)testPurpose
{
    DPSMessage* msg = [self messageFromSample];
    STAssertEquals(msg.purpose, [sample[@"purpose"] charValue], @"Purpose differs");
}

- (void)testSender
{
    DPSMessage* msg = [self messageFromSample];
    STAssertEquals(msg.sender, [sample[@"sender"] unsignedIntValue], @"Sender differs");
}

- (void)testReceiver
{
    DPSMessage* msg = [self messageFromSample];
    STAssertEquals(msg.receiver, [sample[@"receiver"] unsignedIntValue], @"Receiver differs");
}

- (void)testPayload
{
    DPSMessage* msg = [self messageFromSample];
    STAssertEqualObjects(msg.payload, sample[@"payload"], @"Payload differs");
}

- (void)testDictionaryFromFields
{
    DPSMessage* msg = [self messageFromSample];
    NSDictionary* fields = [msg dictionaryFromFields];

    STAssertEqualObjects(fields, sample, @"Fields differ");
}

@end
