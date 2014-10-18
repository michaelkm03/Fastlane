//
//  VUploadManager.m
//  victorious
//
//  Created by Josh Hinman on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Private.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"
#import "VUploadTaskSerializer.h"

static const NSInteger kConcurrentTaskLimit = 1; ///< Number of concurrent uploads. The NSURLSession API may also enforce its own limit on this number.

static NSString * const kDirectoryName = @"VUploadManager"; ///< The directory where pending uploads and configuration files are stored
static NSString * const kUploadBodySubdirectory = @"Uploads"; ///< A subdirectory of the directory above, where HTTP bodies are stored
static NSString * const kInProgressTaskListFilename = @"tasks"; ///< The file where information for current tasks is stored
static NSString * const kPendingTaskListFilename = @"pendingTasks"; ///< The file where information for pending tasks is stored
static NSString * const kURLSessionIdentifier = @"com.victorious.VUploadManager.urlSession";

NSString * const VUploadManagerTaskBeganNotification = @"VUploadManagerTaskBeganNotification";
NSString * const VUploadManagerTaskProgressNotification = @"VUploadManagerTaskProgressNotification";
NSString * const VUploadManagerTaskFinishedNotification = @"VUploadManagerTaskFinishedNotification";
NSString * const VUploadManagerTaskFailedNotification = @"VUploadManagerTaskFailedNotification";
NSString * const VUploadManagerUploadTaskUserInfoKey = @"VUploadManagerUploadTaskUserInfoKey";
NSString * const VUploadManagerBytesSentUserInfoKey = @"VUploadManagerBytesSentUserInfoKey";
NSString * const VUploadManagerTotalBytesUserInfoKey = @"VUploadManagerTotalBytesUserInfoKey";
NSString * const VUploadManagerErrorUserInfoKey = @"VUploadManagerErrorUserInfoKey";

NSString * const VUploadManagerErrorDomain = @"VUploadManagerErrorDomain";
const NSInteger VUploadManagerCouldNotStartUploadErrorCode = 100;

static char kSessionQueueSpecific;

static inline BOOL isSessionQueue()
{
    return dispatch_get_specific(&kSessionQueueSpecific) != NULL;
}

@interface VUploadManager () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) dispatch_queue_t sessionQueue; ///< serializes all URL session operations
@property (nonatomic, readonly) dispatch_queue_t callbackQueue; ///< all callbacks should be made asynchronously on this queue
@property (nonatomic, strong) NSMapTable *taskInformationBySessionTask; ///< Stores all VUploadTaskInformation objects referenced by their associated NSURLSessionTasks
@property (nonatomic, strong) NSMutableArray *pendingTaskInformation; ///< Array of pending tasks
@property (nonatomic, strong) NSMutableArray *taskInformation; ///< Array of in-progress or failed upload tasks
@property (nonatomic, strong) NSMapTable *completionBlocksForPendingTasks;
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
        _completionBlocksForPendingTasks = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableCopyIn];
        _responseData = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory];
        dispatch_queue_set_specific(_sessionQueue, &kSessionQueueSpecific, &kSessionQueueSpecific, NULL);
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startURLSession
{
    [self startURLSessionWithCompletion:nil];
}

- (void)startURLSessionWithCompletion:(void(^)(void))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        [self _startURLSessionWithCompletion:^(void)
        {
            if (completion)
            {
                dispatch_async(self.callbackQueue, ^(void)
                {
                    completion();
                });
            }
        }];
    });
}

- (void)_startURLSessionWithCompletion:(void(^)(void))completion
{
    NSAssert(isSessionQueue(), @"This method must be run on the sessionQueue");
    VLog(@"starting url session");
    if (!self.tasksInProgressSerializer)
    {
        self.tasksInProgressSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:[self urlForInProgressTaskList]];
    }
    
    if (!self.tasksPendingSerializer)
    {
        self.tasksPendingSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:[self urlForPendingTaskList]];
    }
    
    if (!self.urlSession)
    {
        NSArray *savedTasks = [self.tasksInProgressSerializer uploadTasksFromDisk];
        if (savedTasks)
        {
            self.taskInformation = [savedTasks mutableCopy];
        }
        else
        {
            self.taskInformation = [[NSMutableArray alloc] init];
        }
        
        NSArray *pendingTasks = [self.tasksPendingSerializer uploadTasksFromDisk];
        if (pendingTasks)
        {
            self.pendingTaskInformation = [pendingTasks mutableCopy];
        }
        else
        {
            self.pendingTaskInformation = [[NSMutableArray alloc] init];
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
            dispatch_async(self.sessionQueue, ^(void)
            {
                VLog(@"getting current tasks: %lu", (unsigned long)uploadTasks.count);
                // Reconnect in-progress upload tasks with their VUploadTaskInformation instances
                if (self.taskInformation.count)
                {
                    for (NSURLSessionUploadTask *task in uploadTasks)
                    {
                        VUploadTaskInformation *taskInformation = [self informationForSessionTask:task];
                        
                        if (taskInformation)
                        {
                            [self.taskInformationBySessionTask setObject:taskInformation forKey:task];
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:self.objectManager];
                
                if (completion)
                {
                    completion();
                }
            });
        }];
    }
    else if (completion)
    {
        completion();
    }
}

- (BOOL)isYourBackgroundURLSession:(NSString *)backgroundSessionIdentifier
{
    return [kURLSessionIdentifier isEqualToString:backgroundSessionIdentifier];
}

#pragma mark - Queue Management

- (void)enqueueUploadTask:(VUploadTaskInformation *)uploadTask onComplete:(VUploadManagerTaskCompleteBlock)complete
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        [self _enqueueUploadTask:uploadTask onComplete:complete];
    });
}

- (void)_enqueueUploadTask:(VUploadTaskInformation *)uploadTask onComplete:(VUploadManagerTaskCompleteBlock)complete
{
    NSAssert(isSessionQueue(), @"This method must be run on the sessionQueue");
    [self _startURLSessionWithCompletion:^(void)
    {
        NSURL *uploadBodyFileURL = [[self uploadBodyDirectoryURL] URLByAppendingPathComponent:uploadTask.bodyFilename];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[uploadBodyFileURL path]])
        {
            if (complete)
            {
                dispatch_async(self.callbackQueue, ^(void)
                {
                    complete(nil, nil, nil, [NSError errorWithDomain:VUploadManagerErrorDomain code:VUploadManagerCouldNotStartUploadErrorCode userInfo:nil]);
                });
            }
            return;
        }
        
        if (self.taskInformationBySessionTask.count >= kConcurrentTaskLimit)
        {
            [self.pendingTaskInformation addObject:uploadTask];
            [self.tasksPendingSerializer saveUploadTasks:self.pendingTaskInformation];
            
            if (complete)
            {
                [self.completionBlocksForPendingTasks setObject:complete forKey:uploadTask];
            }
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskBeganNotification
                                                                object:self
                                                              userInfo:@{VUploadManagerUploadTaskUserInfoKey: uploadTask}];
        });
        
        if ([self.taskInformation containsObject:uploadTask])
        {
            [self.taskInformation removeObject:uploadTask];
        }
        [self.taskInformation addObject:uploadTask];
        [self.tasksInProgressSerializer saveUploadTasks:self.taskInformation];
        
        NSMutableURLRequest *request = [uploadTask.request mutableCopy];
        [self.objectManager updateHTTPHeadersInRequest:request];
        NSURLSessionUploadTask *uploadSessionTask = [self.urlSession uploadTaskWithRequest:request fromFile:uploadBodyFileURL];
        
        if (!uploadSessionTask)
        {
            NSError *uploadError = [NSError errorWithDomain:VUploadManagerErrorDomain code:VUploadManagerCouldNotStartUploadErrorCode userInfo:nil];
            if (complete)
            {
                dispatch_async(self.callbackQueue, ^(void)
                {
                   complete(nil, nil, nil, uploadError);
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskFailedNotification
                                                                    object:uploadTask
                                                                  userInfo:@{VUploadManagerErrorUserInfoKey: uploadError,
                                                                             VUploadManagerUploadTaskUserInfoKey: uploadTask}];
            });

            return;
        }
        
        if (complete)
        {
           [self.completionBlocks setObject:complete forKey:uploadSessionTask];
        }
        [self.taskInformationBySessionTask setObject:uploadTask forKey:uploadSessionTask];
        
        uploadSessionTask.taskDescription = [uploadTask.identifier UUIDString];
        [uploadSessionTask resume];
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

- (void)cancelUploadTask:(VUploadTaskInformation *)uploadTask
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        for (NSURLSessionTask *sessionTask in [self.taskInformationBySessionTask keyEnumerator])
        {
            if ([[self.taskInformationBySessionTask objectForKey:sessionTask] isEqual:uploadTask])
            {
                [sessionTask cancel];
                break;
            }
        }
        if ([self.pendingTaskInformation containsObject:uploadTask])
        {
            [self.pendingTaskInformation removeObject:uploadTask];
            [self.tasksPendingSerializer saveUploadTasks:self.pendingTaskInformation];
        }
    });
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

- (VUploadTaskInformation *)informationForSessionTask:(NSURLSessionTask *)task
{
    NSAssert(isSessionQueue(), @"This method must be run on the sessionQueue");
    VUploadTaskInformation *cachedInformation = [self.taskInformationBySessionTask objectForKey:task];
    
    if (cachedInformation)
    {
        return cachedInformation;
    }
    NSUUID *identifier = [[NSUUID alloc] initWithUUIDString:task.taskDescription];

    if (!identifier)
    {
        return nil;
    }
    NSArray *taskInformation = [self.taskInformation filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K=%@", NSStringFromSelector(@selector(identifier)), identifier]];
    
    if (taskInformation.count)
    {
        return taskInformation[0];
    }
    return nil;
}

- (void)removeFromQueue:(VUploadTaskInformation *)taskInformation
{
    NSAssert(isSessionQueue(), @"This method must be run on the sessionQueue");
    [self.taskInformation removeObject:taskInformation];
    [self.tasksInProgressSerializer saveUploadTasks:self.taskInformation];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:[[self uploadBodyDirectoryURL] URLByAppendingPathComponent:taskInformation.bodyFilename] error:&error])
    {
        VLog(@"Error deleting finished upload body: %@", [error localizedDescription]);
    }
}

- (void)startNextWaitingTask
{
    NSAssert(isSessionQueue(), @"This method must be run on the sessionQueue");
    
    BOOL __block authorized = NO;
    dispatch_sync(dispatch_get_main_queue(), ^(void)
    {
        authorized = [self.objectManager authorized];
    });
    if (!authorized)
    {
        return;
    }
    
    if (self.pendingTaskInformation.count)
    {
        VUploadTaskInformation *nextUpload = self.pendingTaskInformation[0];
        [self.pendingTaskInformation removeObjectAtIndex:0];
        [self.tasksPendingSerializer saveUploadTasks:self.pendingTaskInformation];
        
        VUploadManagerTaskCompleteBlock completionBlock = [self.completionBlocksForPendingTasks objectForKey:nextUpload];
        if (completionBlock)
        {
            [self.completionBlocksForPendingTasks removeObjectForKey:nextUpload];
        }
        
        [self _enqueueUploadTask:nextUpload onComplete:completionBlock];
    }
}

#pragma mark - Filesystem

- (NSURL *)urlForNewUploadBodyFile
{
    NSString *uniqueID = [[NSUUID UUID] UUIDString];
    return [[self uploadBodyDirectoryURL] URLByAppendingPathComponent:uniqueID];
}

- (NSURL *)urlForInProgressTaskList
{
    return [[self configurationDirectoryURL] URLByAppendingPathComponent:kInProgressTaskListFilename];
}

- (NSURL *)urlForPendingTaskList
{
    return [[self configurationDirectoryURL] URLByAppendingPathComponent:kPendingTaskListFilename];
}

- (NSURL *)configurationDirectoryURL
{
    return [[self documentsDirectory] URLByAppendingPathComponent:kDirectoryName];
}

- (NSURL *)uploadBodyDirectoryURL
{
    return [[self configurationDirectoryURL] URLByAppendingPathComponent:kUploadBodySubdirectory];
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

#pragma mark - Response Parsing

- (NSDictionary *)parsedResponseFromData:(NSData *)responseData parsedError:(NSError *__autoreleasing *)error
{
    NSDictionary *jsonObject = nil;
    @try
    {
        jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    }
    @catch (NSException *exception)
    {
    }
    
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSInteger errorCode = [jsonObject[kVErrorKey] integerValue];
        if (errorCode)
        {
            if (error)
            {
                *error = [NSError errorWithDomain:kVictoriousErrorDomain
                                             code:errorCode
                                         userInfo:nil];
            }
        }
        return jsonObject;
    }
    return nil;
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
        VUploadTaskInformation *taskInformation = [self.taskInformationBySessionTask objectForKey:task];
        if (taskInformation)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskProgressNotification
                                                                    object:taskInformation
                                                                  userInfo:@{ VUploadManagerBytesSentUserInfoKey: @(totalBytesSent),
                                                                              VUploadManagerTotalBytesUserInfoKey: @(totalBytesExpectedToSend),
                                                                              VUploadManagerUploadTaskUserInfoKey: taskInformation,
                                                                            }];
            });
        }
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
    VLog(@"task did complete with error: %@", error.localizedDescription);
    dispatch_async(self.sessionQueue, ^(void)
    {
        NSError *victoriousError = nil;
        NSDictionary *jsonObject = nil;
        NSData *data = [self.responseData objectForKey:task];
        
        if (data)
        {
            jsonObject = [self parsedResponseFromData:data parsedError:&victoriousError];
            if (victoriousError)
            {
                [self.objectManager defaultErrorHandlingForCode:victoriousError.code];
            }
            [self.responseData removeObjectForKey:task];
        }
        
        VUploadTaskInformation *taskInformation = [self informationForSessionTask:task];
        if (taskInformation)
        {
            VLog(@"matched task with information: %@", taskInformation.identifier.UUIDString);
            if (error || victoriousError)
            {
                if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)
                {
                    [self removeFromQueue:taskInformation];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskFailedNotification
                                                                        object:taskInformation
                                                                      userInfo:@{VUploadManagerErrorUserInfoKey: error ?: victoriousError,
                                                                                 VUploadManagerUploadTaskUserInfoKey: taskInformation}];
                });
            }
            else
            {
                [self removeFromQueue:taskInformation];
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskFinishedNotification
                                                                        object:taskInformation
                                                                      userInfo:@{VUploadManagerUploadTaskUserInfoKey: taskInformation}];
                });
            }
        }
        
        [self.taskInformationBySessionTask removeObjectForKey:task];
        
        VUploadManagerTaskCompleteBlock completionBlock = [self.completionBlocks objectForKey:task];
        if (completionBlock)
        {
            // An intentional exception to the "all callbacks made on self.callbackQueue" rule
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                completionBlock(task.response, data, jsonObject, error ?: victoriousError);
            });
            [self.completionBlocks removeObjectForKey:task];
        }

        [self startNextWaitingTask];
    });
}

#pragma mark - NSNotification handlers

- (void)loggedInChanged:(NSNotification *)notification
{
    [self startURLSessionWithCompletion:^(void)
    {
        dispatch_async(self.sessionQueue, ^(void)
        {
            [self startNextWaitingTask];
        });
    }];
}

@end
