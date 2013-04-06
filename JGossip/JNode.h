//
//  JNode.h
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JNode : NSObject
@property (nonatomic, readonly) uint32_t nodeID;

+ (instancetype)nodeWithID:(uint32_t)nodeID;
@end
