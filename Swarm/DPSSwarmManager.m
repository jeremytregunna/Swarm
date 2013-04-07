//
//  DPSSwarmManager.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSSwarmManager.h"

@interface DPSSwarmManager ()
@property (readwrite, getter = isRunning) BOOL running;
@end

@implementation DPSSwarmManager
{
    dispatch_queue_t _socketQueue;
    NSMutableArray* _connectedSockets;
    GCDAsyncSocket* _listenSocket;
}

- (id)init
{
    if((self = [super init]))
    {
        _socketQueue = dispatch_queue_create("ca.tregunna.libs.gossip.swarm-manager", NULL);
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        _running = NO;
    }
    return self;
}

- (void)listen
{
    NSError* error = nil;
    if(![_listenSocket acceptOnPort:JSWARM_PORT error:&error])
    {
        JDLog(@"Error starting server: %@", error);
        return;
    }

    JDLog(@"Starting server on port %hu", [_listenSocket localPort]);
    self.running = YES;
}

- (void)connectToNodes:(NSArray*)nodes
{
    // TODO: Implement.
}

#pragma mark - Socket delegate

- (void)socket:(GCDAsyncSocket*)sock didAcceptNewSocket:(GCDAsyncSocket*)newSocket
{
    @synchronized(_connectedSockets)
    {
        [_connectedSockets addObject:newSocket];
    }

    NSString* host = [newSocket connectedHost];
    uint16_t port = [newSocket connectedPort];

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            JDLog(@"Accepted client %@:%hu", host, port);
        }
    });

    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:JSWARM_READ_TIMEOUT tag:0];
}

- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag
{
    // TODO: Implement protocol.
}

- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag
{
    // TODO: Implement protocol.
}

- (NSTimeInterval)socket:(GCDAsyncSocket*)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if(elapsed <= JSWARM_READ_TIMEOUT)
    {
        // TODO: Request update from socket, extend read timeout.
        return JSWARM_READ_TIMEOUT_EXTENSION;
    }

    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)error
{
    if(sock != _listenSocket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                JDLog(@"Client disconnected");
            }
        });

        @synchronized(_connectedSockets)
        {
            [_connectedSockets removeObject:sock];
        }
    }
}

@end
