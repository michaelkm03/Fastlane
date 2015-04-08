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

@interface VDeeplinkReceiver : NSObject

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 A deeplink URL that came in before we were ready for it.  Calling code can set
 a URL here if the reason to queue exists it the context of the calling code,
 then call `receiveQueuedDeeplink` later on when appropriate.
 */
@property (nonatomic, strong) NSURL *queuedURL;

/**
 Executes any queued deep links by forwarding it to `receiveDeeplink:` method.
 */
- (void)receiveQueuedDeeplink;

/**
 Executes the deep link URL by forwarding it onto the appropriate handler or queues if necessary.
 */
- (void)receiveDeeplink:(NSURL *)url;

@end
