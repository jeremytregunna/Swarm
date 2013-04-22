//
//  SwarmNodeIDGenerator.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwarmNodeIDGenerator : NSObject

+ (uint64_t)nodeID;
+ (NSString*)getMacAddress;

@end
