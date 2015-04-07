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

@interface VDownloadManager ()

@property (nonatomic, strong) NSURLSession *downloadSession;

@end

@implementation VDownloadManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return self;
}

#pragma mark - Public Methods

- (void)enqueueDownloadTask:(VDownloadTaskInformation *)downloadTask
                 onComplete:(VDownloadManagerTaskCompleteBlock)taskCompletion
{
    NSURLSessionDownloadTask *sessionDownloadTask = [self.downloadSession downloadTaskWithRequest:downloadTask.request
                                                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
                                                     {
#warning handle error
                                                         [[NSFileManager defaultManager] createDirectoryAtURL:[downloadTask.downloadLocation URLByDeletingLastPathComponent]
                                                                                  withIntermediateDirectories:YES
                                                                                                   attributes:nil
                                                                                                        error:nil];
                                                         
                                                         [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                 toURL:downloadTask.downloadLocation
                                                                                                 error:nil];
                                                         if (taskCompletion)
                                                         {
                                                             taskCompletion(downloadTask.downloadLocation, response, error);
                                                         }
                                                     }];
    if (!sessionDownloadTask)
    {
#warning Handle Error
        return;
    }
    [sessionDownloadTask resume];
}

@end
