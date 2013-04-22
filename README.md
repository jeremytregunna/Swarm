# Swarm
Copyright © 2013, Jeremy Tregunna, All Rights Reserved.

Swarm is a fault-tolerant communications protocol. A complete description of the protocol is [available here](http://jeremy.tregunna.ca/post/48612729309/introducing-swarm).

Based on a distributed architecture, nodes communicate with each other of a **directed acyclic graph** to the immediately connected nodes only. Nodes which receive a message, forward that message on to the directly connected nodes, until all the nodes have seen the message. We break loops by requiring all messages be logged in a history, and check that before processing each message. If a node receives a message it already knows about, it ignores it and will not forward it.

You can include this project in your iOS and OS X applications.

## Installation

I recommend you fetch the project and add it to yours by using git submodules, though how you bring it into your project is entirely up to your discretion. To do this, run from the root of your project:

    mkdir -p Vendor
    git submodule add https://github.com/jeremytregunna/Swarm.git Vendor/Swarm

From this point, open your build settings for your app target, find your `Header Search Paths` and place the following in there:

    "$(SOURCE_ROOT)/Vendor/Swarm"

The quotes may not be necessary, but include them anyway to avoid problems with spaces in path names.

From this point, drag the Swarm project file into your project, and open your target build phases. Add a target dependency on the Swarm static library or framework target, depending on if you're building something for iOS or OS X.

## Using

First things first, you'll need a history data source object. Add a new class to your project, and make it confrom to the `SwarmHistoryDataSource` protocol, available in `SwarmHistoryItem.h`. There are two required methods you must implement, and for the purposes of this tutorial, I've implemented them like this:

    @implementation MessageHistorySource
    {
        NSMutableArray* _history;
    }
    
    - (id)init
    {
        self = [super init];
        _history = [NSMutableArray array];
        return self;
    }
    
    - (void)storeHistoryItem:(SwarmHistoryItem*)historyItem
    {
        [_history addObject:historyItem];
    }
    
    - (SwarmHistoryItem*)historyItemForMessageID:(NSUUID*)messageID
    {
        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(SwarmHistoryItem* historyItem, NSDictionary* bindings) {
            return [historyItem.messageID isEqual:messageID];
        }];
        NSArray* filteredArray = [_history filteredArrayUsingPredicate:predicate];
        return [filteredArray lastObject];
    }
   
   @end

Obviously, a real implementation of this protocol won't use an in-memory storage if there will be lots of traffic over the network. Instead consider using Core Data, or some other storage system capable of persisting records out to disk. `SwarmHistoryItem` does conform to `NSCoding` to provide you with multiple options for persisting the messages out to your desired medium.

Finally, we need to set up your node. This only requires a few lines of code, and in this example we'll be connecting the nodes using Bonjour. This sample is fully functional:

    MessageHistorySource* historyWriter = [[HATMessageHistorySource alloc] init];
    SwarmNode* root = [SwarmNode nodeWithID:[SwarmNodeIDGenerator nodeID]];
    SwarmCoordinator* coordinator = [[SwarmCoordinator alloc] initWithNode:root historyDataSource:historyWriter];
    [coordinator listenOnPort:0];
    [coordinator startScanningForPeers];

We must create a node first, then set up a coordinator for the swarm. The coordinator's job is to manage the DAG. You send messages through it, connect to other nodes through it, received messages are forwarded, etc. It's the heart and sole of the swarm.

## Contributing

If you think you can help out, with code, documentation, whatever. Let me know. Preferably, use a pull request and attach test code along with your code. Please also see [this document](https://github.com/jeremytregunna/Swarm/blob/master/CONTRIBUTING.md) for information on our contributors agreement.
