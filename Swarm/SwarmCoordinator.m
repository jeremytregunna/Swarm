//
//  SwarmCoordinator.m
//  Swarm
//
//  Created by Jeremy Tregunna on 2013-04-21.
//  Copyright (c) 2013 Jeremy Tregunna. All rights reserved.
//

#import "SwarmCoordinator.h"
#import "SwarmNode.h"
#import "SwarmMessage.h"
#import "SwarmHistoryItem.h"
#import "SwarmBonjourServer.h"
#import "SwarmBonjourClient.h"
#import "MessagePack.h"
#import <JVectorClock/JVectorClock.h>

// Time in seconds
static uint64_t SwarmNodeHeartbeatFrequency       = 300 * NSEC_PER_SEC;
static uint64_t SwarmNodeHeartbeatFrequencyLeeway = 10 * NSEC_PER_SEC;

@interface SwarmCoordinator ()
@property (readwrite, getter = isRunning) BOOL running;
@property (nonatomic, strong) GCDAsyncSocket* listenSocket;

- (void)sendHeartbeats;
@end

@implementation SwarmCoordinator
{
    dispatch_queue_t _socketQueue;
    NSMutableArray* _connectedSockets;
    NSMutableDictionary* _routingTable;
    dispatch_queue_t _timerQueue;
    dispatch_source_t _timer;

    SwarmBonjourServer* _bonjourServer;
    SwarmBonjourClient* _bonjourClient;

    JVectorClock* _clock;
}

- (instancetype)initWithNode:(SwarmNode*)node
{
    return [self initWithNode:node historyDataSource:nil];
}

- (instancetype)initWithNode:(SwarmNode*)node historyDataSource:(id<SwarmHistoryDataSource>)historyDataSource
{
    if((self = [super init]))
    {
        _me = node;
        _clock = [[JVectorClock alloc] init];
        self.historyDataSource = historyDataSource;
        _socketQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        _routingTable = [NSMutableDictionary dictionary];
        _running = NO;

        _timerQueue = dispatch_queue_create("ca.tregunna.swarm.timer", 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
        if(_timer)
        {
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), SwarmNodeHeartbeatFrequency, SwarmNodeHeartbeatFrequencyLeeway);
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

#pragma mark - Listening

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

    if(_bonjourServer == nil)
        _bonjourServer = [[SwarmBonjourServer alloc] initWithCoordinator:self];
    [_bonjourServer advertiseForSocket:_listenSocket];

    JDLog(@"Starting server on port %hu", _listenSocket.localPort);
    self.running = YES;
}

- (void)stopListening
{
    [_bonjourServer stopAdvertising];
    [_listenSocket disconnect];

    @synchronized(_connectedSockets)
    {
        [_connectedSockets makeObjectsPerformSelector:@selector(disconnect)];
    }
}

#pragma mark - Connecting

- (void)startScanningForPeers
{
    if(_bonjourClient == nil)
        _bonjourClient = [[SwarmBonjourClient alloc] initWithCoordinator:self];
    [_bonjourClient startScanningForPeers];
}

- (void)connectToAddresses:(NSArray*)addrs withNodeID:(uint64_t)nodeID
{
    for(NSData* addr in addrs)
    {
        @autoreleasepool {
            GCDAsyncSocket* asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
            NSError* error = nil;
            if(![asyncSocket connectToAddress:addr withTimeout:SWARM_READ_TIMEOUT error:&error])
            {
                JDLog(@"Error connecting to %@. Reason: %@", addr, error);
            }
            else
            {
                _routingTable[@(nodeID)] = asyncSocket;
                [_clock forkClockForNodeID:nodeID];
            }
        }
    }
}

#pragma mark - Sending

- (void)sendHeartbeats
{
    for(NSNumber* nodeID in _routingTable)
    {
        uint64_t nID = self.me.nodeID;
        GCDAsyncSocket* sock = _routingTable[nodeID];
        NSDictionary* options = @{ @"sender": @(nID), @"clock": _clock[@(nID + 1)] };
        NSData* data = [options messagePack];

        if([sock isConnected])
        {
            [_clock forkClockForNodeID:nID];
            [sock writeData:data withTimeout:20.0f tag:SwarmMessagePurposeHeartbeat];
            JDLog(@"Sent heartbeat: %@ to Node ID: %@", options, nodeID);
        }
    }
}

- (BOOL)sendMessage:(SwarmMessage*)msg
{
    [_clock forkClockForNodeID:msg.sender];
    msg.clock = [_clock[@(msg.sender)] unsignedLongLongValue];

    NSDictionary* fieldOptions = [msg dictionaryFromFields];
    NSData* data = [fieldOptions messagePack];

    [_listenSocket writeData:data withTimeout:SWARM_READ_TIMEOUT tag:SwarmMessagePurposePayload];

    for(GCDAsyncSocket* sock in _connectedSockets)
    {
        if(sock != nil && [sock isConnected])
        {
            [sock writeData:data withTimeout:SWARM_READ_TIMEOUT tag:SwarmMessagePurposePayload];
            return YES;
        }
    }

    return NO;
}

- (BOOL)sendMessage:(SwarmMessage*)msg toNode:(uint32)nodeID
{
    [_clock forkClockForNodeID:msg.sender];
    msg.clock = [_clock[@(msg.sender)] unsignedLongLongValue];

    NSDictionary* fieldOptions = [msg dictionaryFromFields];
    NSData* data = [fieldOptions messagePack];

    GCDAsyncSocket* sock = _routingTable[@(nodeID)];
    if(sock != nil && [sock isConnected])
    {
        [sock writeData:data withTimeout:20.0f tag:SwarmMessagePurposePayload];
        return YES;
    }

    return NO;
}

- (void)forwardMessageWithOptions:(NSDictionary*)options
{
    NSMutableDictionary* forwardOptions = [options mutableCopy];
    forwardOptions[@"forwardedBy"] = @(self.me.nodeID);
    SwarmMessage* msg = [SwarmMessage messageWithDictionary:forwardOptions];
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
        [_clock forkClockForNodeID:self.me.nodeID];

        if([self.delegate respondsToSelector:@selector(didAcceptNewConnectionToSwarmCoordinator:)])
            [self.delegate didAcceptNewConnectionToSwarmCoordinator:self];
        JDLog(@"Accepted client %@:%hu", host, port);
    });

    [newSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag
{
    if([data length] <= 2)
        return;

    NSDictionary* options = [data messagePackParse];

    if(tag == SwarmMessagePurposeHeartbeat)
    {
        @synchronized(_routingTable)
        {
            _routingTable[@([options[@"sender"] unsignedLongLongValue])] = sock;
        }
        return;
    }

    if(tag == SwarmMessagePurposePayload)
    {
        NSUUID* messageID = options[@"messageID"];
        if(messageID && [self.historyDataSource historyItemForMessageID:messageID] == nil)
        {
            uint64_t nodeID = self.me.nodeID;
            [_clock forkClockForNodeID:nodeID];

            SwarmHistoryItem* historyItem = [SwarmHistoryItem historyItemWithMessageID:messageID];
            [self.historyDataSource storeHistoryItem:historyItem];

            if([options[@"receiver"] isEqual:@(nodeID)])
            {
                SwarmMessage* msg = [SwarmMessage messageWithDictionary:options];
                [self.delegate swarmCoordinator:self didReceiveMessage:msg];
            }

            [self forwardMessageWithOptions:options];
        }
    }
    else if(tag == SwarmMessagePurposeReplay)
    {
        NSNumber* nodeID = options[@"sender"];
        NSNumber* clockNumber = options[@"clock"];

        NSArray* messages = [self.delegate swarmCoordinator:self node:nodeID messagesSinceClock:[clockNumber unsignedLongLongValue]];
        for(SwarmMessage* msg in messages)
            [self sendMessage:msg];
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket*)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if(elapsed <= SWARM_READ_TIMEOUT)
        return SWARM_READ_TIMEOUT_EXTENSION;
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)error
{
    [_clock forkClockForNodeID:self.me.nodeID];

    if(sock != _listenSocket)
    {
        @synchronized(_connectedSockets)
        {
            [_connectedSockets removeObject:sock];
            NSUInteger idx = [[_routingTable allValues] indexOfObject:sock];
            if(idx != NSNotFound)
            {
                NSNumber* key = [[_routingTable allKeys] objectAtIndex:idx];
                [_routingTable removeObjectForKey:key];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(didDisconnectConnectionFromSwarmCoordinator:withError:)])
                [self.delegate didDisconnectConnectionFromSwarmCoordinator:self withError:error];
        });
    }

    if([_listenSocket isConnected] == NO && [_connectedSockets count] == 0)
    {
        self.running = NO;
        if([self.delegate respondsToSelector:@selector(swarmCoordinatorDidStopRunning:)])
            [self.delegate swarmCoordinatorDidStopRunning:self];
    }
}

@end
