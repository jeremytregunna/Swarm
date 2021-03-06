//
//  JBonjourServer.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket, SwarmCoordinator;

@interface SwarmBonjourServer : NSObject <NSNetServiceDelegate>

- (instancetype)initWithCoordinator:(SwarmCoordinator*)coordinator;

- (void)advertiseForSocket:(GCDAsyncSocket*)socket;
- (void)stopAdvertising;

@end
