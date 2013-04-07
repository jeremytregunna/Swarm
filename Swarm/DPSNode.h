//
//  DPSNode.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DPSNodeHistoryDataSource;
@class JHistoryItem;

@interface DPSNode : NSObject
@property (nonatomic, readonly) uint32_t nodeID;
@property (nonatomic, readonly, weak) id<DPSNodeHistoryDataSource> historyDataSource;

+ (instancetype)nodeWithID:(uint32_t)nodeID;
@end

@protocol DPSNodeHistoryDataSource <NSObject>
- (JHistoryItem*)historyItemForMessageID:(NSUUID*)messageID;
- (void)didReceiveHistoryItemForMessageID:(NSUUID*)messageID;
@end
