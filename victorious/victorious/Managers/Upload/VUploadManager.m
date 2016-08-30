//
//  VUploadManager.m
//  victorious
//
//  Created by Josh Hinman on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "victorious-Swift.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"
#import "VUploadTaskSerializer.h"

#define UPLOADS_SHOULD_FAIL 0 // Set to 1 to test the failed upload UI. WARNING: Uploads will look like they failed, but will actually go through!

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
const NSInteger VUploadManagerBadHTTPResponseErrorCode = 200;

static char kSessionQueueSpecific;

#ifndef NS_BLOCK_ASSERTIONS
static inline BOOL isSessionQueue()
{
    return dispatch_get_specific(&kSessionQueueSpecific) != NULL;
}
#endif

@interface VUploadManager () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) id<PersistentStoreType> persistentStore;
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
    self = [super init];
    if ( self != nil )
    {
        _persistentStore = [PersistentStoreSelector defaultPersistentStore];
        _useBackgroundSession = YES;
        _sessionQueue = dispatch_queue_create("com.victorious.VUploadManager.sessionQueue", DISPATCH_QUEUE_SERIAL);
        _taskInformationBySessionTask = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory];
        _completionBlocks = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableCopyIn];
        _completionBlocksForPendingTasks = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableCopyIn];
        _responseData = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory];
        dispatch_queue_set_specific(_sessionQueue, &kSessionQueueSpecific, &kSessionQueueSpecific, NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
    }
    return self;
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
            if ( completion != nil )
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
    if ( self.tasksInProgressSerializer == nil )
    {
        self.tasksInProgressSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:[self urlForInProgressTaskList]];
    }
    
    if ( self.tasksPendingSerializer == nil )
    {
        self.tasksPendingSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:[self urlForPendingTaskList]];
    }
    
    if ( self.urlSession == nil )
    {
        NSArray *savedTasks = [self.tasksInProgressSerializer uploadTasksFromDisk];
        if (savedTasks)
        {
            self.taskInformation = [self arrayOfTasksByFilteringOutInvalidTasks:savedTasks];
        }
        else
        {
            self.taskInformation = [[NSMutableArray alloc] init];
        }
        
        NSArray *pendingTasks = [self.tasksPendingSerializer uploadTasksFromDisk];
        if ( pendingTasks != nil )
        {
            self.pendingTaskInformation = [self arrayOfTasksByFilteringOutInvalidTasks:pendingTasks];
        }
        else
        {
            self.pendingTaskInformation = [[NSMutableArray alloc] init];
        }
        
        NSURLSessionConfiguration *sessionConfig;
        if (self.useBackgroundSession)
        {
            sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kURLSessionIdentifier];
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
                // Reconnect in-progress upload tasks with their VUploadTaskInformation instances
                if ( self.taskInformation.count != 0 )
                {
                    for (NSURLSessionUploadTask *task in uploadTasks)
                    {
                        VUploadTaskInformation *taskInformation = [self informationForSessionTask:task];
                        
                        if ( taskInformation != nil )
                        {
                            [self.taskInformationBySessionTask setObject:taskInformation forKey:task];
                        }
                    }
                }
                
                if ( completion != nil )
                {
                    completion();
                }
            });
        }];
    }
    else if ( completion != nil )
    {
        completion();
    }
}

- (NSMutableArray *)arrayOfTasksByFilteringOutInvalidTasks:(NSArray *)unfilteredTasks
{
    NSMutableArray *filteredTasks = [[NSMutableArray alloc] initWithCapacity:unfilteredTasks.count];
    for (VUploadTaskInformation *uploadTask in unfilteredTasks)
    {
        if ([uploadTask isKindOfClass:[VUploadTaskInformation class]] && [uploadTask.bodyFilename isKindOfClass:[NSString class]])
        {
            NSURL *bodyFileURL = [[self uploadBodyDirectoryURL] URLByAppendingPathComponent:uploadTask.bodyFilename];
            BOOL isDirectory = YES;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:bodyFileURL.path isDirectory:&isDirectory] && !isDirectory)
            {
                [filteredTasks addObject:uploadTask];
            }
        }
    }
    return filteredTasks;
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
            if ( complete != nil )
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
            
            if ( complete != nil )
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
        
        NSURLSessionUploadTask *uploadSessionTask = [self.urlSession uploadTaskWithRequest:uploadTask.request fromFile:uploadBodyFileURL];
        
        if ( uploadSessionTask == nil )
        {
            NSError *uploadError = [NSError errorWithDomain:VUploadManagerErrorDomain code:VUploadManagerCouldNotStartUploadErrorCode userInfo:nil];
            if ( complete != nil )
            {
                dispatch_async(self.callbackQueue, ^(void)
                {
                   complete(nil, nil, nil, uploadError);
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self trackFailureWithError:uploadError URL:uploadBodyFileURL];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskFailedNotification
                                                                    object:uploadTask
                                                                  userInfo:@{VUploadManagerErrorUserInfoKey: uploadError,
                                                                             VUploadManagerUploadTaskUserInfoKey: uploadTask}];
            });

            return;
        }
        
        if ( complete != nil )
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
    if ( completion != nil )
    {
        [self startURLSessionWithCompletion:^(void)
        {
            dispatch_async(self.sessionQueue, ^(void)
            {
                NSArray *inProgressTasks = [self.taskInformation copy];
                NSArray *pendingTasks = [self.pendingTaskInformation copy];
                dispatch_async(self.callbackQueue, ^(void)
                {
                    completion([pendingTasks arrayByAddingObjectsFromArray:inProgressTasks]);
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
        if ([self.taskInformation containsObject:uploadTask])
        {
            [self.taskInformation removeObject:uploadTask];
            [self.tasksInProgressSerializer saveUploadTasks:self.taskInformation];
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
    if ( task == nil )
    {
        return NO;
    }
    
    BOOL __block isInProgress = NO;
    dispatch_sync(self.sessionQueue, ^(void)
    {
        if ( self.urlSession != nil )
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
    
    if ( cachedInformation != nil )
    {
        return cachedInformation;
    }
    NSUUID *identifier = [[NSUUID alloc] initWithUUIDString:task.taskDescription];
    
    if ( identifier == nil )
    {
        return nil;
    }
    NSArray *taskInformation = [self.taskInformation filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K=%@", NSStringFromSelector(@selector(identifier)), identifier]];
    
    if ( taskInformation.count != 0 )
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
    
    if ( !VCurrentUser.exists )
    {
        return;
    }
    
    if ( self.pendingTaskInformation.count != 0 )
    {
        VUploadTaskInformation *nextUpload = self.pendingTaskInformation[0];
        [self.pendingTaskInformation removeObjectAtIndex:0];
        [self.tasksPendingSerializer saveUploadTasks:self.pendingTaskInformation];
        
        VUploadManagerTaskCompleteBlock completionBlock = [self.completionBlocksForPendingTasks objectForKey:nextUpload];
        if ( completionBlock != nil )
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
    if ( responseData != nil )
    {
        jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    }
    
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSInteger errorCode = [jsonObject[kVErrorKey] integerValue];
        if ( errorCode != 0 )
        {
            if ( error != nil )
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

/**
 Returns YES if the given response code is in the 'OK' range according to the HTTP spec
 */
- (BOOL)isOKResponseCode:(NSInteger)responseCode
{
    return responseCode >= 200 && responseCode < 400;
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
        if ( _backgroundSessionEventsCompleteHandler != nil ) // direct ivar access because calling the property getter would surely deadlock.
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
        if ( taskInformation != nil )
        {
            taskInformation.expectedBytesToSend = totalBytesExpectedToSend;
            taskInformation.bytesSent = totalBytesSent;
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
        
        if ( responseData == nil )
        {
            responseData = [[NSMutableData alloc] init];
            [self.responseData setObject:responseData forKey:dataTask];
        }
        [responseData appendData:data];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#if UPLOADS_SHOULD_FAIL
    error = [NSError errorWithDomain:@"bad error" code:666 userInfo:nil];
#endif
    dispatch_async(self.sessionQueue, ^(void)
    {
        NSError *victoriousError = nil;
        NSDictionary *jsonObject = nil;
        NSData *data = [self.responseData objectForKey:task];
        
        if ( data != nil )
        {
            jsonObject = [self parsedResponseFromData:data parsedError:&victoriousError];
            [self.responseData removeObjectForKey:task];
        }
        
        if ( error == nil && victoriousError == nil && ![self isOKResponseCode:[(NSHTTPURLResponse *)task.response statusCode]] )
        {
            victoriousError = [NSError errorWithDomain:VUploadManagerErrorDomain code:VUploadManagerBadHTTPResponseErrorCode userInfo:nil];
        }
        
        VUploadTaskInformation *taskInformation = [self informationForSessionTask:task];
        if ( taskInformation != nil )
        {
            if ( error != nil || victoriousError != nil )
            {
                if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)
                {
                    [self removeFromQueue:taskInformation];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    [self trackFailureWithError:(error ?: victoriousError) URL:task.currentRequest.URL];
                    
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
                    NSDictionary *params = @{ VTrackingKeyMediaType : [task.currentRequest.URL pathExtension] ?: @"" };
                    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUploadDidSucceed parameters:params];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:VUploadManagerTaskFinishedNotification
                                                                        object:taskInformation
                                                                      userInfo:@{VUploadManagerUploadTaskUserInfoKey: taskInformation}];
                });
            }
        }
        
        [self.taskInformationBySessionTask removeObjectForKey:task];
        
        VUploadManagerTaskCompleteBlock completionBlock = [self.completionBlocks objectForKey:task];
        if ( completionBlock != nil )
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

#pragma mark - Tracking helpers

- (void)trackFailureWithError:(NSError *)error URL:(NSURL *)url
{
    if ( error.code != NSURLErrorCancelled )
    {
        NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"",
                                  VTrackingKeyMediaType : [url pathExtension] ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUploadDidFail parameters:params];
    }
}

#pragma mark -

+ (VUploadManager *)sharedManager
{
    static VUploadManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[VUploadManager alloc] init];
    });
    return sharedManager;
}

- (void)mockCurrentUser
{
    id<PersistentStoreType> persistentStore = [PersistentStoreSelector defaultPersistentStore];
    VUser *user = (VUser *)[[persistentStore mainContext] v_createObjectAndSaveWithEntityName:@"User" configurations:^(NSManagedObject *_Nonnull object) {
        VUser *user = (VUser *)object;
        user.remoteId = @123;
        user.token = @"abcd";
    }];
    [user setAsCurrentUser];
}

@end
