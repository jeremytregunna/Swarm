//
//  HATAppDelegate.m
//  SwarmTest
//
//  Created by Jeremy Tregunna on 2013-04-20.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "HATAppDelegate.h"
#import "Swarm.h"
#import "HATMessageHistorySource.h"
#import "SwarmMacAddressHelper.h"

@implementation HATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    HATMessageHistorySource* historyWriter = [[HATMessageHistorySource alloc] init];
    SwarmNode* root = [SwarmNode nodeWithID:[SwarmMacAddressHelper nodeID]];
    SwarmCoordinator* coordinator = [[SwarmCoordinator alloc] initWithNode:root historyDataSource:historyWriter];
    [coordinator listenOnPort:0];

//    [coordinator connectToNodes:hosts];
    [coordinator startScanningForPeers];
}

@end
