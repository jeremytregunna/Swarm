//
//  JBonjourServer.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "GCDAsyncSocket.h"
#import "SwarmBonjourServer.h"

@implementation SwarmBonjourServer
{
    NSNetService* _netService;
}

- (void)advertiseForSocket:(GCDAsyncSocket*)socket
{
    int port = [socket localPort];
    _netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_swarm._tcp." name:@"" port:port];
    _netService.delegate = self;
    [_netService publish];
}

- (void)stopAdvertising
{
    [_netService stop];
}

#pragma mark - Net service delegate

- (void)netServiceDidPublish:(NSNetService*)ns
{
	JDLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [ns domain], [ns type], [ns name], (int)[ns port]);
}

- (void)netService:(NSNetService*)ns didNotPublish:(NSDictionary*)errorDict
{
	JDLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [ns domain], [ns type], [ns name], errorDict);
}

@end
