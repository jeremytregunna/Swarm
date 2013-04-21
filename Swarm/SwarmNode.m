//
//  SwarmNode.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "SwarmNode.h"

@implementation SwarmNode

+ (instancetype)nodeWithID:(uint32_t)nodeID
{
    return [[self alloc] initWithNodeID:nodeID];
}

- (instancetype)initWithNodeID:(uint32_t)nodeID
{
    if((self = [super init]))
        _nodeID = nodeID;
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [self isEqualToNode:object];
}

- (BOOL)isEqualToNode:(SwarmNode*)node
{
    return _nodeID == node.nodeID;
}

- (NSUInteger)hash
{
    return 31 + _nodeID;
}

@end
