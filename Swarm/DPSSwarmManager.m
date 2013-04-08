//
//  DPSSwarmManager.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-06.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSSwarmManager.h"
#import "DPSMessage.h"
#import "DPSHistoryItem.h"

@interface DPSSwarmManager ()
@property (readwrite, getter = isRunning) BOOL running;
@property (readwrite, copy) NSMutableArray* history;
@end

@implementation DPSSwarmManager
{
    dispatch_queue_t _socketQueue;
    NSMutableArray* _connectedSockets;
    GCDAsyncSocket* _listenSocket;
    NSMutableArray* _history;
    NSMutableDictionary* _heartbeats;
}

- (id)init
{
    if((self = [super init]))
    {
        _socketQueue = dispatch_queue_create("ca.tregunna.libs.gossip.swarm-manager", NULL);
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        _running = NO;
        _history = [NSMutableArray arrayWithCapacity:1];
        _heartbeats = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)listen
{
    [self listenOnPort:JSWARM_PORT];
}

- (void)listenOnPort:(uint16_t)port
{
    NSError* error = nil;
    if(![_listenSocket acceptOnPort:port error:&error])
    {
        JDLog(@"Error starting server: %@", error);
        return;
    }

    JDLog(@"Starting server on port %hu", [_listenSocket localPort]);
    self.running = YES;
}

- (void)connectToNodes:(NSArray*)nodes
{
    for(NSString* hostAndPortString in nodes)
    {
        @autoreleasepool {
            NSArray* hostComponents = [hostAndPortString componentsSeparatedByString:@":"];
            NSString* hostName = hostComponents[0];
            uint16_t port;
            if([hostComponents count] > 1)
                port = [hostComponents[1] unsignedShortValue];
            else
                port = JSWARM_PORT;

            GCDAsyncSocket* asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
            NSError* error = nil;
            if(![asyncSocket connectToHost:hostName onPort:port withTimeout:JSWARM_READ_TIMEOUT error:&error])
            {
                JDLog(@"Error connecting to %@. Reason: %@", hostAndPortString, error);
            }
        }
    }
}

#pragma mark - Sending

- (BOOL)sendMessage:(DPSMessage*)msg
{
    NSDictionary* fieldOptions = [msg dictionaryFromFields];
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:fieldOptions options:0 error:&error];
    if(error != nil)
    {
        JDLog(@"JSON encoding error when sending: %@", error);
        return NO;
    }

    [_listenSocket writeData:data withTimeout:JSWARM_READ_TIMEOUT tag:DPSMessagePurposePayload];

    for(GCDAsyncSocket* sock in _connectedSockets)
    {
        [sock writeData:data withTimeout:JSWARM_READ_TIMEOUT tag:DPSMessagePurposePayload];
    }

    return YES;
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

    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag
{
    if([data length] == 2)
        return;

    NSError* error = nil;
    NSDictionary* options = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error != nil)
    {
        JDLog(@"Invalid JSON, error: %@", error);
        return;
    }

    @synchronized(_history)
    {
        NSUUID* messageID = options[@"messageID"];
        if(messageID && [_history containsObject:messageID] == NO)
        {
            [_history addObject:messageID];

            JDLog(@"JSON received: %@", options);

            // TODO: Forward message.
        }
    }
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
    else if([_listenSocket isConnected] == NO && [_connectedSockets count] == 0)
        self.running = NO;
}

@end
