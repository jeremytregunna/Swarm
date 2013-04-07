//
//  JNode.m
//  JGossip
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "JNode.h"

@interface JNode ()
- (instancetype)initWithNodeID:(uint32_t)nodeID;
@end

@implementation JNode
{
    NSMutableArray* _connectedSockets;
}

+ (instancetype)nodeWithID:(uint32_t)nodeID
{
    return [[self alloc] initWithNodeID:nodeID];
}

- (instancetype)initWithNodeID:(uint32_t)nodeID
{
    if((self = [super init]))
    {
        _nodeID = nodeID;
        _connectedSockets = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

@end
