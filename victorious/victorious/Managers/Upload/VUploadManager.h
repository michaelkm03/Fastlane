//
//  VUploadManager.h
//  victorious
//
//  Created by Josh Hinman on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VObjectManager, VUploadTaskInformation, VUploadTaskSerializer;

/**
 A block to be called when an upload task is completed.
 
 @param response The response from the remote server
 @param responseData The body of the response
 @param jsonResponse The body of the response, parsed as a JSON dictionary, if available
 @param error if the request failed, this object will have more information
 */
typedef void (^VUploadManagerTaskCompleteBlock)(NSURLResponse *response, NSData *responseData, NSDictionary *jsonResponse, NSError *error);

extern NSString * const VUploadManagerTaskBeganNotification; ///< Sent when a new upload task begins
extern NSString * const VUploadManagerTaskProgressNotification; ///< Sent periodically during an upload
extern NSString * const VUploadManagerTaskFinishedNotification; ///< Sent when an upload task finishes successfully
extern NSString * const VUploadManagerTaskFailedNotification; ///< Sent when an upload task fails

extern NSString * const VUploadManagerUploadTaskUserInfoKey; ///< An instance of VUploadTaskInformation describing the upload
extern NSString * const VUploadManagerBytesSentUserInfoKey; ///< The total number of bytes sent so far
extern NSString * const VUploadManagerTotalBytesUserInfoKey; ///< The total number of bytes to be sent in this request
extern NSString * const VUploadManagerErrorUserInfoKey; ///< An NSError object explaining why an upload failed

/**
 Manages background upload tasks
 */
@interface VUploadManager : NSObject

@property (nonatomic, weak, readonly) VObjectManager *objectManager; ///< The objectManager passed to the -init call

/**
 If YES (default), uploads will happen via a background session.
 This is really only meant to be set to NO for unit testing.
 */
@property (nonatomic) BOOL useBackgroundSession;

/**
 A serializer object that will be used to save upload tasks to disk.
 This is here for unit testing purposes--there is a good default
 that will be used if this not set.
 */
@property (nonatomic, strong) VUploadTaskSerializer *taskSerializer;

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
 A unique URL where the body for a future upload can be stored.
 The directories in this URL's path are not guaranteed to
 exist, so please create them if needed.
 */
- (NSURL *)urlForNewUploadBodyFile;

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
 Asynchronously retrieves a list of previously-queued upload tasks.
 The list passed to the completion block will not include tasks
 that have completed successfully. Additionally, these tasks may
 not actually be in the process of uploading--call
 -isTaskInProgress: to get that information.
 */
- (void)getQueuedUploadTasksWithCompletion:(void (^)(NSArray /* VUploadTaskInformation */ *tasks))completion;

/**
 Attempts to cancel an in-progress upload task. If the task
 is not currently in progress, it will be removed from
 the queue.
 */
- (void)cancelUploadTask:(VUploadTaskInformation *)uploadTask;

/**
 Returns YES if the task is being uploaded.
 */
- (BOOL)isTaskInProgress:(VUploadTaskInformation *)task;

@end
