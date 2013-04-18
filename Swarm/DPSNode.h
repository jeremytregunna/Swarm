//
//  DPSNode.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol DPSNodeHistoryDataSource, DPSNodeDelegate;
@class DPSHistoryItem, DPSMessage;

// This is a candidate to be refactored. DPSNode contains two independent parts at the moment: Swarm control, and Node information.
// We should be able to extract node information out of swarm control at some future point.
@interface DPSNode : NSObject <GCDAsyncSocketDelegate>
@property (nonatomic, readonly) uint32_t nodeID;
@property (nonatomic, weak) id<DPSNodeDelegate> delegate;
@property (nonatomic, readonly, weak) id<DPSNodeHistoryDataSource> historyDataSource;
@property (readonly, getter = isRunning) BOOL running;

+ (instancetype)nodeWithID:(uint32_t)nodeID historyDataSource:(id<DPSNodeHistoryDataSource>)historyDataSource;

- (void)listen;
- (void)listenOnPort:(uint16_t)port;
- (void)stopListening;
- (void)connectToNodes:(NSArray*)nodes;

- (BOOL)sendMessage:(DPSMessage*)msg;
- (BOOL)sendMessage:(DPSMessage*)msg toNode:(uint32)nodeID;
@end

@protocol DPSNodeHistoryDataSource <NSObject>
@required
- (DPSHistoryItem*)historyItemForMessageID:(NSUUID*)messageID;
- (void)storeHistoryItem:(DPSHistoryItem*)historyItem;
@end

@protocol DPSNodeDelegate <NSObject>
@required
- (void)node:(DPSNode*)node didReceiveMessage:(DPSMessage*)msg;
@optional
- (void)didAcceptNewClientForNode:(DPSNode*)node;
- (void)didDisconnectClientFromNode:(DPSNode*)node withError:(NSError*)error;
- (void)nodeDidStopRunning:(DPSNode*)node;
@end
