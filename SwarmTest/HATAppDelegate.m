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

@implementation HATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    __block NSMutableArray* hosts = [NSMutableArray array];
    
    HATMessageHistorySource* historyWriter = [[HATMessageHistorySource alloc] init];
    SwarmNode* root = [SwarmNode nodeWithID:1];
    SwarmCoordinator* coordinator = [[SwarmCoordinator alloc] initWithNode:root historyDataSource:historyWriter];
    [coordinator listen];

    [coordinator connectToNodes:hosts];
}

@end