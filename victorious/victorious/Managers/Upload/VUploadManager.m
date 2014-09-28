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

static NSString * const kDirectoryName = @"VUploadManager"; ///< The directory where pending uploads and configuration files are stored
static NSString * const kUploadBodySubdirectory = @"Uploads"; ///< A subdirectory of the directory above, where HTTP bodies are stored
static NSString * const kTaskListFilename = @"tasks"; ///< The file where information for current tasks is stored
static NSString * const kURLSessionIdentifier = @"com.victorious.VUploadManager.urlSession";

@interface VUploadManager () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) dispatch_queue_t sessionQueue; ///< serializes all URL session operations
@property (nonatomic, strong) NSMapTable *completionBlocks;

@end

@implementation VUploadManager
{
    void (^_backgroundSessionEventsCompleteHandler)();
}

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _sessionQueue = dispatch_queue_create("com.victorious.VUploadManager.sessionQueue", DISPATCH_QUEUE_SERIAL);
        _completionBlocks = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableCopyIn];
    }
    return self;
}

- (void)startURLSession
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        if (!self.urlSession)
        {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:kURLSessionIdentifier];
            self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
            [self.urlSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks)
            {
                // TODO: resume tracking of upload tasks
            }];
        }
    });
}

- (void)enqueueUploadTask:(VUploadTaskInformation *)uploadTask onComplete:(VUploadManagerTaskCompleteBlock)complete
{
    [self startURLSession];
    dispatch_async(self.sessionQueue, ^(void)
    {
        NSMutableURLRequest *request = [uploadTask.request mutableCopy];
        [self.objectManager updateHTTPHeadersInRequest:request];
        NSURLSessionUploadTask *uploadSessionTask = [self.urlSession uploadTaskWithRequest:request fromFile:uploadTask.bodyFileURL];
        
        if (complete)
        {
            [self.completionBlocks setObject:complete forKey:uploadSessionTask];
        }
        [uploadSessionTask resume];
    });
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
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        VUploadManagerTaskCompleteBlock completionBlock = [self.completionBlocks objectForKey:task];
        if (completionBlock)
        {
            completionBlock(error);
            [self.completionBlocks removeObjectForKey:task];
        }
    });
}

@end
