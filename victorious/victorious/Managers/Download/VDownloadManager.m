//
//  VDownloadManager.m
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDownloadManager.h"

#import "VDownloadTaskInformation.h"

static NSString * const kURLSessionIdentifier = @"com.victorious.VDownloadManager.urlSession";
static NSString * const kDownloadMangerErrorDomain = @"VDwonloadManagerErrorDomain";

@interface VDownloadManager () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *downloadSession;

@property (nonatomic, strong) VDownloadTaskInformation *currentDownloadTask;
@property (nonatomic, copy) VDownloadManagerTaskProgressBlock progressBlockForDownloadTask;
@property (nonatomic, copy) VDownloadManagerTaskCompleteBlock completionBlockForDownloadTask;

@end

@implementation VDownloadManager

- (instancetype)init
{
    VLog(@"ATTENTION: FOR DEMO PURPOSES ONLY");
    self = [super init];
    if (self)
    {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                         delegate:self
                                                    delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark - Public Methods

- (void)enqueueDownloadTask:(VDownloadTaskInformation *)downloadTask
               withProgress:(VDownloadManagerTaskProgressBlock)taskProgress
                 onComplete:(VDownloadManagerTaskCompleteBlock)taskCompletion
{
    self.currentDownloadTask = downloadTask;
    self.progressBlockForDownloadTask = taskProgress;
    self.completionBlockForDownloadTask = taskCompletion;
    
    NSURLSessionDownloadTask *sessionDownloadTask = [self.downloadSession downloadTaskWithRequest:downloadTask.request];
    
    if (!sessionDownloadTask)
    {
        if (taskCompletion != nil)
        {
            taskCompletion(nil, [NSError errorWithDomain:kDownloadMangerErrorDomain
                                                    code:0
                                                userInfo:nil]);
        }
        return;
    }
    [sessionDownloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == 0)
    {
        return;
    }
    CGFloat progress = (CGFloat) totalBytesWritten / totalBytesExpectedToWrite;
    
    if (self.progressBlockForDownloadTask != nil)
    {
        self.progressBlockForDownloadTask(progress);
    }
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    [[NSFileManager defaultManager] createDirectoryAtURL:[self.currentDownloadTask.downloadLocation URLByDeletingLastPathComponent]
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:self.currentDownloadTask.downloadLocation
                                            error:nil];
    if (self.completionBlockForDownloadTask)
    {
        self.completionBlockForDownloadTask(self.currentDownloadTask.downloadLocation, nil);
    }
    
    self.progressBlockForDownloadTask = nil;
    self.completionBlockForDownloadTask = nil;
    self.currentDownloadTask = nil;
}

@end
