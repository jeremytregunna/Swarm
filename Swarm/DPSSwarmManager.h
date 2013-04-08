//
//  DPSSwarmManager.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class DPSMessage;

@interface DPSSwarmManager : NSObject <GCDAsyncSocketDelegate>
@property (readonly, getter = isRunning) BOOL running;
@property (readonly, copy) NSArray* history;

- (void)listen;
- (void)listenOnPort:(uint16_t)port;
- (void)connectToNodes:(NSArray*)nodes;

- (BOOL)sendMessage:(DPSMessage*)msg;
@end
