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

@interface VDownloadOperation ()

@property (nonatomic, readonly) VDownloadOperationCompletion completion;
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
    
    self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:self.url
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        if ( error != nil || ![self isOKResponseCode:[(NSHTTPURLResponse *)response statusCode]] )
        {
            NSError *errorToPassToCompletionBlock = error;
            if ( errorToPassToCompletionBlock == nil )
            {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                NSString *errorMessage = [NSString stringWithFormat:@"%ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
                errorToPassToCompletionBlock = [NSError errorWithDomain:VDownloadOperationErrorDomain code:VDownloadOperationErrorBadStatusCode userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
            }
            
            // purposely using NSLog rather than VLog; I want this log to be present in release builds to help troubleshoot template errors at runtime.
            NSLog( @"Error downloading [%@]: %@", self.url.absoluteString, errorToPassToCompletionBlock.localizedDescription );
            
            if ( self.completion != nil )
            {
                self.completion(errorToPassToCompletionBlock, response, nil);
            }
            return;
        }
        if ( self.completion != nil )
        {
            self.completion(nil, response, location);
        }
        dispatch_semaphore_signal(self.semaphore);
    }];
    [self.downloadTask resume];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (void)cancel
{
    [super cancel];
    [self.downloadTask cancel];
    dispatch_semaphore_signal(self.semaphore);
}

/**
 Returns YES if the given response code is in the 'OK' range according to the HTTP spec
 */
- (BOOL)isOKResponseCode:(NSInteger)responseCode
{
    return responseCode >= 200 && responseCode < 400;
}

@end
