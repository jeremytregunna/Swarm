//
//  JNode.h
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JNodeHistoryDataSource;
@class JHistoryItem;

@interface JNode : NSObject
@property (nonatomic, readonly) uint32_t nodeID;
@property (nonatomic, readonly, weak) id<JNodeHistoryDataSource> historyDataSource;

+ (instancetype)nodeWithID:(uint32_t)nodeID;
@end

@protocol JNodeHistoryDataSource <NSObject>
- (JHistoryItem*)historyItemForMessageID:(NSUUID*)messageID;
- (void)didReceiveHistoryItemForMessageID:(NSUUID*)messageID;
@end
