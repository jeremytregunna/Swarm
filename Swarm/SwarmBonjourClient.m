//
//  SwarmBonjourClient.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "SwarmBonjourClient.h"
#import "SwarmCoordinator.h"

@implementation SwarmBonjourClient
{
    __weak SwarmCoordinator* _coordinator;
    NSNetServiceBrowser* _netServiceBrowser;

    NSNetService* serverService;
}

- (instancetype)initWithCoordinator:(SwarmCoordinator*)coordinator
{
    if((self = [super init]))
    {
        _coordinator = coordinator;

        _netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        _netServiceBrowser.delegate = self;
    }
    return self;
}

- (void)startScanningForPeers
{
    [_netServiceBrowser searchForServicesOfType:@"_swarm._tcp." inDomain:@"local."];
}

#pragma mark - Net service browser delegate

- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didFindService:(NSNetService*)aNetService moreComing:(BOOL)moreComing
{
    JDLog(@"Found service name: %@", [aNetService name]);

    if(serverService == nil)
    {
        serverService = aNetService;

        serverService.delegate = self;
        [serverService resolveWithTimeout:5.0f];
    }
}

#pragma mark - Net service delegate

- (void)netServiceDidResolveAddress:(NSNetService*)sender
{
    NSArray* addresses = [sender addresses];
    if([addresses count] > 0)
        [_coordinator connectToAddresses:addresses withNodeID:[[sender name] intValue]];
}

@end
