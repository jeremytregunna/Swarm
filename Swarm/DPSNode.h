//
//  DPSNode.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol DPSNodeHistoryDataSource;
@class DPSHistoryItem, DPSMessage;

@interface DPSNode : NSObject <GCDAsyncSocketDelegate>
@property (nonatomic, readonly) uint32_t nodeID;
@property (nonatomic, readonly, weak) id<DPSNodeHistoryDataSource> historyDataSource;
@property (readonly, getter = isRunning) BOOL running;

+ (instancetype)nodeWithID:(uint32_t)nodeID historyDataSource:(id<DPSNodeHistoryDataSource>)historyDataSource;

- (void)listen;
- (void)listenOnPort:(uint16_t)port;
- (void)connectToNodes:(NSArray*)nodes;

- (BOOL)sendMessage:(DPSMessage*)msg;
@end

@protocol DPSNodeHistoryDataSource <NSObject>
- (DPSHistoryItem*)historyItemForMessageID:(NSUUID*)messageID;
- (void)storeHistoryItem:(DPSHistoryItem*)historyItem;
@end
