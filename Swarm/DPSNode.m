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

@interface DPSNode ()
@property (readwrite, getter = isRunning) BOOL running;
@property (nonatomic, strong) GCDAsyncSocket* listenSocket;

- (instancetype)initWithNodeID:(uint32_t)nodeID historyDataSource:(id<DPSNodeHistoryDataSource>)historyDataSource;
@end

@implementation DPSNode
{
    dispatch_queue_t _socketQueue;
    NSMutableArray* _connectedSockets;
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
        _running = NO;
    }
    return self;
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
        [sock writeData:data withTimeout:SWARM_READ_TIMEOUT tag:DPSMessagePurposePayload];
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
    if(tag == DPSMessagePurposeHeartbeat || [data length] == 2)
        return;

    NSError* error = nil;
    NSDictionary* options = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error != nil)
    {
        JDLog(@"Invalid JSON, error: %@", error);
        return;
    }

    NSUUID* messageID = options[@"messageID"];
    if(messageID && [self.historyDataSource historyItemForMessageID:messageID] == nil)
    {
        DPSHistoryItem* historyItem = [DPSHistoryItem historyItemWithMessageID:messageID];
        [self.historyDataSource storeHistoryItem:historyItem];

        JDLog(@"JSON received: %@", options);

        // TODO: Forward message.
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
