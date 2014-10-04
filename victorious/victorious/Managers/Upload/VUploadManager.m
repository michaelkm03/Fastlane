//
//  VUploadManager.m
//  victorious
//
//  Created by Josh Hinman on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Private.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"
#import "VUploadTaskSerializer.h"

static NSString * const kDirectoryName = @"VUploadManager"; ///< The directory where pending uploads and configuration files are stored
static NSString * const kUploadBodySubdirectory = @"Uploads"; ///< A subdirectory of the directory above, where HTTP bodies are stored
static NSString * const kTaskListFilename = @"tasks"; ///< The file where information for current tasks is stored
static NSString * const kURLSessionIdentifier = @"com.victorious.VUploadManager.urlSession";

NSString * const VUploadManagerTaskBeganNotification = @"VUploadManagerTaskBeganNotification";
NSString * const VUploadManagerTaskProgressNotification = @"VUploadManagerTaskProgressNotification";
NSString * const VUploadManagerTaskFinishedNotification = @"VUploadManagerTaskFinishedNotification";
NSString * const VUploadManagerTaskFailedNotification = @"VUploadManagerTaskFailedNotification";
NSString * const VUploadManagerUploadTaskUserInfoKey = @"VUploadManagerUploadTaskUserInfoKey";
NSString * const VUploadManagerBytesSentUserInfoKey = @"VUploadManagerBytesSentUserInfoKey";
NSString * const VUploadManagerTotalBytesUserInfoKey = @"VUploadManagerTotalBytesUserInfoKey";
NSString * const VUploadManagerErrorUserInfoKey = @"VUploadManagerErrorUserInfoKey";

@interface VUploadManager () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) dispatch_queue_t sessionQueue; ///< serializes all URL session operations
@property (nonatomic, readonly) dispatch_queue_t callbackQueue; ///< all callbacks should be made asynchronously on this queue
@property (nonatomic, strong) NSMapTable *taskInformationBySessionTask; ///< Stores all VUploadTaskInformation objects referenced by their associated NSURLSessionTasks
@property (nonatomic, strong) NSMutableArray *taskInformation; ///< Array of all queued upload tasks
@property (nonatomic, strong) NSMapTable *completionBlocks;
@property (nonatomic, strong) NSMapTable *responseData;

@end

@implementation VUploadManager
{
    void (^_backgroundSessionEventsCompleteHandler)();
}

- (id)init
{
    return [self initWithObjectManager:nil];
}

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _useBackgroundSession = YES;
        _objectManager = objectManager;
        _sessionQueue = dispatch_queue_create("com.victorious.VUploadManager.sessionQueue", DISPATCH_QUEUE_SERIAL);
        _taskInformationBySessionTask = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory];
        _completionBlocks = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableCopyIn];
        _responseData = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory];
    }
    return self;
}

- (void)startURLSessionWithCompletion:(void(^)(void))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        if (!self.urlSession)
        {
            NSArray *savedTasks = [self.taskSerializer uploadTasksFromDisk];
            if (savedTasks)
            {
                self.taskInformation = [savedTasks mutableCopy];
            }
            else
            {
                self.taskInformation = [[NSMutableArray alloc] init];
            }
            
            NSURLSessionConfiguration *sessionConfig;
            if (self.useBackgroundSession)
            {
                sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:kURLSessionIdentifier];
            }
            else
            {
                sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            }
            self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
            [self.urlSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks)
            {
                // Reconnect in-progress upload tasks with their VUploadTaskInformation instances
                if (self.taskInformation.count)
                {
                    for (NSURLSessionUploadTask *task in uploadTasks)
                    {
                        NSUUID *identifier = [[NSUUID alloc] initWithUUIDString:task.taskDescription];
                        if (identifier)
                        {
                            NSArray *taskInformation = [self.taskInformation filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K=%@", NSStringFromSelector(@selector(identifier)), identifier]];
                            if (taskInformation.count)
                            {
                                [self.taskInformationBySessionTask setObject:taskInformation[0] forKey:task];
                            }
                        }
                    }
                }
                
                if (completion)
                {
                    dispatch_async(self.callbackQueue, ^(void)
                    {
                        completion();
                    });
                }
            }];
        }
        else if (completion)
        {
            dispatch_async(self.callbackQueue, ^(void)
            {
                completion();
            });
        }
    });
}

- (void)enqueueUploadTask:(VUploadTaskInformation *)uploadTask onComplete:(VUploadManagerTaskCompleteBlock)complete
{
    [self startURLSessionWithCompletion:^(void)
    {
        dispatch_async(self.sessionQueue, ^(void)
        {
            NSMutableURLRequest *request = [uploadTask.request mutableCopy];
            [self.objectManager updateHTTPHeadersInRequest:request];
            NSURLSessionUploadTask *uploadSessionTask = [self.urlSession uploadTaskWithRequest:request fromFile:uploadTask.bodyFileURL];

            if (complete)
            {
               [self.completionBlocks setObject:complete forKey:uploadSessionTask];
            }
            [self.taskInformationBySessionTask setObject:uploadTask forKey:uploadSessionTask];
            [self.taskInformation addObject:uploadTask];
            [self.taskSerializer saveUploadTasks:self.taskInformation];
            uploadSessionTask.taskDescription = [uploadTask.identifier UUIDString];
            [uploadSessionTask resume];
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskBeganNotification
                                                                    object:self
                                                                  userInfo:@{VUploadManagerUploadTaskUserInfoKey: uploadTask,
                                                                        }];
            });
        });
    }];
}

- (void)getQueuedUploadTasksWithCompletion:(void (^)(NSArray *tasks))completion
{
    if (completion)
    {
        [self startURLSessionWithCompletion:^(void)
        {
            dispatch_async(self.sessionQueue, ^(void)
            {
                NSArray *tasks = [self.taskInformation copy];
                dispatch_async(self.callbackQueue, ^(void)
                {
                    completion(tasks);
                });
            });
        }];
    }
}

- (BOOL)isTaskInProgress:(VUploadTaskInformation *)task
{
    if (!task)
    {
        return NO;
    }
    
    BOOL __block isInProgress = NO;
    dispatch_sync(self.sessionQueue, ^(void)
    {
        if (self.urlSession)
        {
            for (VUploadTaskInformation *taskInProgress in [self.taskInformationBySessionTask objectEnumerator])
            {
                if ([taskInProgress isEqual:task])
                {
                    isInProgress = YES;
                    return;
                }
            }
        }
        else
        {
            isInProgress = NO;
        }
    });
    return isInProgress;
}

#pragma mark - Filesystem

- (NSURL *)urlForNewUploadBodyFile
{
    NSURL *directory = [[self configurationDirectoryURL] URLByAppendingPathComponent:kUploadBodySubdirectory];
    NSString *uniqueID = [[NSUUID UUID] UUIDString];
    return [directory URLByAppendingPathComponent:uniqueID];
}

- (NSURL *)urlForUploadTaskList
{
    return [[self configurationDirectoryURL] URLByAppendingPathComponent:kTaskListFilename];
}

- (NSURL *)configurationDirectoryURL
{
    return [[self documentsDirectory] URLByAppendingPathComponent:kDirectoryName];
}

- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

#pragma mark - Properties

- (dispatch_queue_t)callbackQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)setBackgroundSessionEventsCompleteHandler:(void (^)(void))backgroundSessionEventsCompleteHandler
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        _backgroundSessionEventsCompleteHandler = [backgroundSessionEventsCompleteHandler copy];
    });
}

- (void (^)(void))backgroundSessionEventsCompleteHandler
{
    void __block (^backgroundSessionEventsCompleteHandler)();
    dispatch_sync(self.sessionQueue, ^(void)
    {
        backgroundSessionEventsCompleteHandler = _backgroundSessionEventsCompleteHandler;
    });
    return backgroundSessionEventsCompleteHandler;
}

- (void)setUseBackgroundSession:(BOOL)useBackgroundSession
{
    NSAssert(self.urlSession == nil, @"Can't change useBackgroundSession property after the session has already been created");
    _useBackgroundSession = useBackgroundSession;
}

#pragma mark - NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        // TODO: cancel any outstanding tasks
        VLog(@"URLSession has become invalid: %@", [error localizedDescription]);
        self.urlSession = nil;
    });
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        if (_backgroundSessionEventsCompleteHandler) // direct ivar access because calling the property getter would surely deadlock.
        {
            _backgroundSessionEventsCompleteHandler();
            _backgroundSessionEventsCompleteHandler = nil;
        }
    });
}

#pragma mark - NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            userInfo[VUploadManagerBytesSentUserInfoKey] = @(totalBytesSent);
            userInfo[VUploadManagerTotalBytesUserInfoKey] = @(totalBytesExpectedToSend);
            
            VUploadTaskInformation *taskInformation = [self.taskInformationBySessionTask objectForKey:task];
            if (taskInformation)
            {
                userInfo[VUploadManagerUploadTaskUserInfoKey] = taskInformation;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskProgressNotification
                                                                object:self
                                                              userInfo:userInfo];
        });
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        NSMutableData *responseData = [self.responseData objectForKey:dataTask];
        
        if (!responseData)
        {
            responseData = [[NSMutableData alloc] init];
            [self.responseData setObject:responseData forKey:dataTask];
        }
        [responseData appendData:data];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        VUploadManagerTaskCompleteBlock completionBlock = [self.completionBlocks objectForKey:task];
        NSData *data = [self.responseData objectForKey:task];
        
        if (data)
        {
            [self.responseData removeObjectForKey:task];
        }
        
        if (!error)
        {
            VUploadTaskInformation *taskInformation = [self.taskInformationBySessionTask objectForKey:task];
            if (taskInformation)
            {
                [[NSFileManager defaultManager] removeItemAtURL:taskInformation.bodyFileURL error:nil];
                [self.taskInformationBySessionTask removeObjectForKey:task];
                [self.taskInformation removeObject:taskInformation];
                [self.taskSerializer saveUploadTasks:self.taskInformation];
            }
        }
        
        if (completionBlock)
        {
            // An intentional exception to the "all callbacks made on self.callbackQueue" rule
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                completionBlock(task.response, data, error);
            });
            [self.completionBlocks removeObjectForKey:task];
        }
    });
}

@end
