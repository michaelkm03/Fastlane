//
//  VDownloadOperation.m
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDownloadOperation.h"

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
    __block NSTimeInterval retryTimer = self.retryInterval;
    __block BOOL success = NO;
    self.semaphore = dispatch_semaphore_create(0);
    
    while ( !success )
    {
        self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:self.url
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
        {
            if ( error != nil || ![self isOKResponseCode:[(NSHTTPURLResponse *)response statusCode]] )
            {
                NSString *errorMessage = error.localizedDescription;
                if ( errorMessage == nil )
                {
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    errorMessage = [NSString stringWithFormat:@"%ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
                }
                
                // purposely using NSLog rather than VLog; I want this log to be present in release builds to help troubleshoot template errors at runtime.
                NSLog( @"Error downloading [%@]: %@", self.url.absoluteString, errorMessage );
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryTimer * NSEC_PER_SEC)),
                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                               ^(void)
                {
                    retryTimer *= 2;
                    dispatch_semaphore_signal(self.semaphore);
                });
                return;
            }
            if ( self.completion != nil )
            {
                self.completion(location);
            }
            success = YES;
            dispatch_semaphore_signal(self.semaphore);
        }];
        [self.downloadTask resume];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
        if ( self.cancelled )
        {
            break;
        }
    }
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
