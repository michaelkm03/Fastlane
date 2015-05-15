//
//  VDeeplinkReceiver.h
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VScaffoldViewController.h"

@class VDependencyManager;

/**
 This class should be used to receive deep links from the app delegate.  It handles
 propagating the deepLink handling behavior to navigation destinations and their children that
 are provided by the scaffold (which itself is provided in the VDependencyManager property).
 */
@interface VDeeplinkReceiver : NSObject

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Let's callign code know if any deep links can be received at this time.
 */
@property (nonatomic, assign, readonly) BOOL canReceiveDeeplinks;

/**
 Executes the deep link URL by forwarding it onto the appropriate handler or queues if necessary.
 */
- (void)receiveDeeplink:(NSURL *)url;

/**
 Explicitly queues a deepLink which can be receive later on by calling `receiveQueuedDeeplink`.
 There can only be one queued deepLink at a time, so calling this will override any existing deepLink
 previously queued.  Passing nil for `url` parameter will cancel any queued deepLink.
 */
- (void)queueDeeplink:(NSURL *)url;

/**
 Executes a queued deep link URL by forwarding it onto the appropriate handler or queues if necessary.
 */
- (void)receiveQueuedDeeplink;

@end
