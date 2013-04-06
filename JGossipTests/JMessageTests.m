//
//  JMessageTests.m
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "JMessageTests.h"
#import "JMessage.h"

@implementation JMessageTests
{
    NSDictionary* sample;
}

- (void)setUp
{
    [super setUp];

    sample = @{
        @"purpose": @(JMessagePurposePayload),
        @"sender": @(1),
        @"receiver": @(2),
        @"payload": @{ @"test": @"data" }
    };
}

- (JMessage*)messageFromSample
{
    return [JMessage messageWithPurpose:[sample[@"purpose"] charValue] from:[sample[@"sender"] unsignedIntValue] to:[sample[@"receiver"] unsignedIntValue] withPayload:sample[@"payload"]];
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
