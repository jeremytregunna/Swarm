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
    DPSNode* root = [DPSNode nodeWithID:1 historyDataSource:historyWriter];
    [root listen];
    
    [root connectToNodes:hosts];
}

@end
