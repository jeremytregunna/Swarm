//
//  SwarmCoordinator.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class SwarmNode, SwarmMessage;
@protocol SwarmDelegate, SwarmHistoryDataSource;

@interface SwarmCoordinator : NSObject <GCDAsyncSocketDelegate>
@property (nonatomic, readonly, strong) SwarmNode* me;
@property (nonatomic, weak) id<SwarmDelegate> delegate;
@property (nonatomic, weak) id<SwarmHistoryDataSource> historyDataSource;
@property (readonly, getter = isRunning) BOOL running;

- (instancetype)initWithNode:(SwarmNode*)node;
- (instancetype)initWithNode:(SwarmNode*)node historyDataSource:(id<SwarmHistoryDataSource>)historyDataSource;

- (void)listen;
- (void)listenOnPort:(uint16_t)port;
- (void)stopListening;
- (void)startScanningForPeers;
- (void)connectToAddresses:(NSArray*)addrs withNodeID:(uint64_t)nodeID;

- (BOOL)sendMessage:(SwarmMessage*)msg;
- (BOOL)sendMessage:(SwarmMessage*)msg toNode:(uint32)nodeID;

@end

@protocol SwarmDelegate <NSObject>
@required
- (void)swarmCoordinator:(SwarmCoordinator*)coordinator didReceiveMessage:(SwarmMessage*)msg;
- (NSArray*)swarmCoordinator:(SwarmCoordinator*)coordinator node:(NSNumber*)nodeID messagesSinceClock:(uint64_t)clock;
@optional
- (void)didAcceptNewConnectionToSwarmCoordinator:(SwarmCoordinator*)coordinator;
- (void)didDisconnectConnectionFromSwarmCoordinator:(SwarmCoordinator*)coordinator withError:(NSError*)error;
- (void)swarmCoordinatorDidStopRunning:(SwarmCoordinator*)coordinator;
@end
