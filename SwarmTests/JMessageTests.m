//
//  JMessageTests.m
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "JMessageTests.h"
#import "JMessage.h"

@interface JMessage (PrivateMethods)
@property (nonatomic, readwrite, strong) NSUUID* messageID;
@end

@implementation JMessageTests
{
    NSDictionary* sample;
}

- (void)setUp
{
    [super setUp];

    sample = @{
        @"messageID": [[NSUUID alloc] initWithUUIDString:@"68753A44-4D6F-1226-9C60-0050E4C00067"],
        @"purpose": @(JMessagePurposePayload),
        @"sender": @(1),
        @"receiver": @(2),
        @"payload": @{ @"test": @"data" }
    };
}

- (JMessage*)messageFromSample
{
    JMessage* msg = [JMessage messageWithPurpose:[sample[@"purpose"] charValue] from:[sample[@"sender"] unsignedIntValue] to:[sample[@"receiver"] unsignedIntValue] withPayload:sample[@"payload"]];
    msg.messageID = sample[@"messageID"];
    return msg;
}

- (void)testMessageID
{
    JMessage* msg = [self messageFromSample];
    STAssertEqualObjects(msg.messageID, sample[@"messageID"], @"Message ID differs");
}

- (void)testPurpose
{
    JMessage* msg = [self messageFromSample];
    STAssertEquals(msg.purpose, [sample[@"purpose"] charValue], @"Purpose differs");
}

- (void)testSender
{
    JMessage* msg = [self messageFromSample];
    STAssertEquals(msg.sender, [sample[@"sender"] unsignedIntValue], @"Sender differs");
}

- (void)testReceiver
{
    JMessage* msg = [self messageFromSample];
    STAssertEquals(msg.receiver, [sample[@"receiver"] unsignedIntValue], @"Receiver differs");
}

- (void)testPayload
{
    JMessage* msg = [self messageFromSample];
    STAssertEqualObjects(msg.payload, sample[@"payload"], @"Payload differs");
}

- (void)testDictionaryFromFields
{
    JMessage* msg = [self messageFromSample];
    NSDictionary* fields = [msg dictionaryFromFields];

    STAssertEqualObjects(fields, sample, @"Fields differ");
}

@end
