//
//  VUploadManager.h
//  victorious
//
//  Created by Josh Hinman on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VObjectManager, VUploadTaskInformation;

/**
 Manages background upload tasks
 */
@interface VUploadManager : NSObject

@property (nonatomic, weak, readonly) VObjectManager *objectManager; ///< The objectManager passed to the -init call

/**
 A completion handler that will be called in response to the NSURLSessionDelegate 
 method URLSessionDidFinishEventsForBackgroundURLSession:
 */
@property (nonatomic, copy) void (^backgroundSessionEventsCompleteHandler)(void);

/**
 The designated initializer.
 
 @param objectManager An instance of VObjectManager used to add authentication headers to HTTP requests.
 */
- (instancetype)initWithObjectManager:(VObjectManager *)objectManager;

/**
 Adds a new upload task to the queue. It will be started
 automatically as soon as items submitted previously are
 completed.
 */
- (void)enqueueUploadTask:(VUploadTaskInformation *)uploadTask;

/**
 A unique URL where the body for a future upload can be stored.
 The directories in this URL's path are not guaranteed to
 exist, so please create them if needed.
 */
- (NSURL *)urlForNewUploadBodyFile;

@end
