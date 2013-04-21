//
//  SwarmBonjourClient.h
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SwarmCoordinator;

@interface SwarmBonjourClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

- (instancetype)initWithCoordinator:(SwarmCoordinator*)coordinator;

- (void)startScanningForPeers;

@end
