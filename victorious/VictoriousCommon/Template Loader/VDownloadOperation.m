//
//  VDownloadOperation.m
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDownloadOperation.h"

NSString * const VDownloadOperationErrorDomain = @"VDownloadOperationErrorDomain";
const NSInteger VDownloadOperationErrorBadStatusCode = 100;
const int64_t kProgressTotalCount = 100;

@interface VDownloadOperation () <NSURLSessionDownloadDelegate>

@property (nonatomic, copy) VDownloadOperationCompletion completion;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSURLSessionTask *downloadTask;

@end

@implementation VDownloadOperation

- (instancetype)initWithURL:(NSURL *)url completion:(VDownloadOperationCompletion)completionBlock
{
    self = [super init];
    if ( self != nil )
    {
        _url = url;
        _completion = [completionBlock copy];
        _retryInterval = 1;
    }
    return self;
}

- (void)main
{
    self.semaphore = dispatch_semaphore_create(0);
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    self.downloadTask = [session downloadTaskWithURL:self.url];
    [self.downloadTask resume];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (void)cancel
{
    [super cancel];
    [self.downloadTask cancel];
}

/**
 Returns YES if the given response code is in the 'OK' range according to the HTTP spec
 */
- (BOOL)isOKResponseCode:(NSInteger)responseCode
{
    return responseCode >= 200 && responseCode < 400;
}

- (void)handleError:(NSError *)error response:(NSURLResponse *)response
{
    // purposely using NSLog rather than VLog; I want this log to be present in release builds to help troubleshoot template errors at runtime.
    NSLog( @"Error downloading [%@]: %@", self.url.absoluteString, error.localizedDescription );

    if ( self.completion != nil )
    {
        self.completion(self.url, error, response, nil);
        self.completion = nil;
    }
}

#pragma mark - NSURLSessionDownloadDelegate methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ( self.isCancelled )
    {
        return;
    }
    if ( downloadTask != self.downloadTask )
    {
        return;
    }
    if ( ![self isOKResponseCode:[(NSHTTPURLResponse *)downloadTask.response statusCode]] )
    {
        NSInteger statusCode = [(NSHTTPURLResponse *)downloadTask.response statusCode];
        NSString *errorMessage = [NSString stringWithFormat:@"%ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
        NSError *error = [NSError errorWithDomain:VDownloadOperationErrorDomain code:VDownloadOperationErrorBadStatusCode userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
        [self handleError:error response:downloadTask.response];
    }
    else
    {
        if ( self.completion != nil )
        {
            self.completion(self.url, nil, downloadTask.response, location);
            self.completion = nil;
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ( task != self.downloadTask )
    {
        return;
    }
    if ( error != nil && !self.isCancelled )
    {
        [self handleError:error response:task.response];
    }
    dispatch_semaphore_signal(self.semaphore);
}

@end
