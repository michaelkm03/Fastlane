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
 A block to be called when an upload task is completed.
 
 @param response The response from the remote server
 @param responseData the body of the response
 @param error if the request failed, this object will have more information
 */
typedef void (^VUploadManagerTaskCompleteBlock)(NSURLResponse *response, NSData *responseData, NSError *error);

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
 
 @param complete Called when the upload is complete. If the 
                 upload fails, the NSError paramer will 
                 contain details about what went wrong. If
                 error is nil, the upload was successful.
 */
- (void)enqueueUploadTask:(VUploadTaskInformation *)uploadTask onComplete:(VUploadManagerTaskCompleteBlock)complete;

/**
 A unique URL where the body for a future upload can be stored.
 The directories in this URL's path are not guaranteed to
 exist, so please create them if needed.
 */
- (NSURL *)urlForNewUploadBodyFile;

@end
