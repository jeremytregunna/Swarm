//
//  JSwarmManager.h
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface JSwarmManager : NSObject <GCDAsyncSocketDelegate>
@property (readonly, getter = isRunning) BOOL running;

- (void)listen;
- (void)connectToNodes:(NSArray*)nodes;
@end
