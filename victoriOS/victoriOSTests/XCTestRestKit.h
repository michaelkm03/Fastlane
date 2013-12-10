//
//  XCTestRestKit.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#ifndef victoriOS_XCTestRestKit_h
#define victoriOS_XCTestRestKit_h

#define XCTestRestKitStartOperation(operation) \
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); \
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); \
    RKManagedObjectRequestOperation *o = operation; \
    o.failureCallbackQueue = queue; o.successCallbackQueue = queue; \
    [o start]; dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
#define XCTestRestKitEndOperation() dispatch_semaphore_signal(semaphore);

#endif
