//
//  SwarmHistoryItem.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwarmHistoryItem : NSObject
@property (nonatomic, readonly, strong) NSUUID* messageID;
@property (nonatomic, getter = isSent) BOOL sent;
@property (nonatomic, readonly, strong) NSDate* sentDate;

+ (instancetype)historyItemWithMessageID:(NSUUID*)messageID;
@end

@protocol SwarmHistoryDataSource <NSObject>
@required
- (SwarmHistoryItem*)historyItemForMessageID:(NSUUID*)messageID;
- (void)storeHistoryItem:(SwarmHistoryItem*)historyItem;
@end
