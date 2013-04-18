//
//  DPSNode.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-05.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "DPSNode.h"
#import "DPSMessage.h"
#import "DPSHistoryItem.h"

// Time in seconds
static NSUInteger DPSNodeHeartbeatFrequency = 300;
static NSUInteger DPSNodeHeartbeatFrequencyLeeway = 10;

@interface DPSNode ()
@property (readwrite, getter = isRunning) BOOL running;
@property (nonatomic, strong) GCDAsyncSocket* listenSocket;

- (instancetype)initWithNodeID:(uint32_t)nodeID historyDataSource:(id<DPSNodeHistoryDataSource>)historyDataSource;

- (void)sendHeartbeats;
@end

@implementation DPSNode
{
    dispatch_queue_t _socketQueue;
    NSMutableArray* _connectedSockets;
    NSMutableDictionary* _leafSet;
    dispatch_queue_t _timerQueue;
    dispatch_source_t _timer;
}

+ (instancetype)nodeWithID:(uint32_t)nodeID historyDataSource:(id<DPSNodeHistoryDataSource>)historyDataSource
{
    return [[self alloc] initWithNodeID:nodeID historyDataSource:historyDataSource];
}

- (instancetype)initWithNodeID:(uint32_t)nodeID historyDataSource:(id<DPSNodeHistoryDataSource>)historyDataSource
{
    if((self = [super init]))
    {
        _nodeID = nodeID;
        _historyDataSource = historyDataSource;
        _socketQueue = dispatch_queue_create("ca.tregunna.libs.swarm.socket", NULL);
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        _leafSet = [NSMutableDictionary dictionary];
        _running = NO;

        _timerQueue = dispatch_queue_create("ca.tregunna.swarm.timer", 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
        if(_timer)
        {
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), DPSNodeHeartbeatFrequency, DPSNodeHeartbeatFrequencyLeeway);
            dispatch_source_set_event_handler(_timer, ^{
                [self sendHeartbeats];
            });
            dispatch_resume(_timer);
        }
    }
    return self;
}

- (void)dealloc
{
    dispatch_source_cancel(_timer);
    _timer = nil;
}

- (void)listen
{
    [self listenOnPort:SWARM_PORT];
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

- (void)stopListening
{
    [_listenSocket disconnect];

    @synchronized(_connectedSockets)
    {
        [_connectedSockets makeObjectsPerformSelector:@selector(disconnect)];
    }

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
                port = (unsigned short)[hostComponents[1] intValue];
            else
                port = SWARM_PORT;

            GCDAsyncSocket* asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
            NSError* error = nil;
            if(![asyncSocket connectToHost:hostName onPort:port withTimeout:SWARM_READ_TIMEOUT error:&error])
            {
                JDLog(@"Error connecting to %@. Reason: %@", hostAndPortString, error);
            }
        }
    }
}

#pragma mark - Sending

- (void)sendHeartbeats
{
    for(NSNumber* nodeID in _leafSet)
    {
        GCDAsyncSocket* sock = _leafSet[nodeID];
        NSDictionary* options = @{
            @"sender": @(self.nodeID)
        };
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:options options:0 error:&error];
        if(error != nil)
        {
            JDLog(@"JSON encoding error when sending: %@", error);
            return;
        }

        if([sock isConnected])
            [sock writeData:data withTimeout:20.0f tag:DPSMessagePurposeHeartbeat];
    }
}

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

    [_listenSocket writeData:data withTimeout:SWARM_READ_TIMEOUT tag:DPSMessagePurposePayload];

    for(GCDAsyncSocket* sock in _connectedSockets)
    {
        if(![sock isConnected])
            [sock writeData:data withTimeout:SWARM_READ_TIMEOUT tag:DPSMessagePurposePayload];
    }

    return YES;
}

- (BOOL)sendMessage:(DPSMessage*)msg toNode:(uint32)nodeID
{
    NSDictionary* fieldOptions = [msg dictionaryFromFields];
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:fieldOptions options:0 error:&error];
    if(error != nil)
    {
        JDLog(@"JSON encoding error when sending: %@", error);
        return NO;
    }

    GCDAsyncSocket* sock = _leafSet[@(nodeID)];
    if(sock != nil && [sock isConnected])
    {
        [sock writeData:data withTimeout:20.0f tag:DPSMessagePurposePayload];
        return YES;
    }

    return NO;
}

- (void)forwardMessageWithOptions:(NSDictionary*)options
{
    NSMutableDictionary* forwardOptions = [options mutableCopy];
    forwardOptions[@"forwardedBy"] = @(self.nodeID);
    DPSMessage* msg = [DPSMessage messageWithDictionary:forwardOptions];
    [self sendMessage:msg];
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
        if([self.delegate respondsToSelector:@selector(didAcceptNewClientForNode:)])
            [self.delegate didAcceptNewClientForNode:self];
        JDLog(@"Accepted client %@:%hu", host, port);
    });

    [newSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
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

    if(tag == DPSMessagePurposeHeartbeat)
    {
        @synchronized(_leafSet)
        {
            [_leafSet setObject:sock forKey:options[@"sender"]];
        }
        return;
    }

    NSUUID* messageID = options[@"messageID"];
    if(messageID && [self.historyDataSource historyItemForMessageID:messageID] == nil)
    {
        DPSHistoryItem* historyItem = [DPSHistoryItem historyItemWithMessageID:messageID];
        [self.historyDataSource storeHistoryItem:historyItem];

        if([options[@"receiver"] isEqual:@(self.nodeID)])
        {
            DPSMessage* msg = [DPSMessage messageWithDictionary:options];
            [self.delegate node:self didReceiveMessage:msg];
        }

        [self forwardMessageWithOptions:options];
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket*)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if(elapsed <= SWARM_READ_TIMEOUT)
    {
        // TODO: Request update from socket, extend read timeout.
        return SWARM_READ_TIMEOUT_EXTENSION;
    }

    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)error
{
    if(sock != _listenSocket)
    {
        @synchronized(_connectedSockets)
        {
            [_connectedSockets removeObject:sock];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(didDisconnectClientFromNode:withError:)])
                [self.delegate didDisconnectClientFromNode:self withError:error];
        });
    }
    if([_listenSocket isConnected] == NO && [_connectedSockets count] == 0)
    {
        self.running = NO;
        if([self.delegate respondsToSelector:@selector(nodeDidStopRunning:)])
            [self.delegate nodeDidStopRunning:self];
    }
}

@end
