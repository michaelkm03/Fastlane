//
//  VDownloadOperation.h
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VDownloadOperationErrorDomain; ///< NSError domain for errors generated by this class (not passed through from an NSURLSession API)
extern const NSInteger VDownloadOperationErrorBadStatusCode; ///< Indicates that a download failed because the status code returned by the server was not in the acceptable range.

/**
 Completion block to be called on an arbitrary background thread when the operation completes.
 
 @param originalURL The URL that was originally requested
 @param error If an error occurs during download, this parameter will have information on the error.
              If the download succeeds, this parameter will be nil.
 @param downloadedFile location on disk of the file that's been downloaded. It will
                       be stored in a temporary location, so it should be moved
                       somewhere more permanent immediately. If file was not suc-
                       cessfully downloaded, this will be nil.
 */
typedef void (^VDownloadOperationCompletion)(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile);

/**
 An NSOperation subclass to download a single 
 file, with retries until it's successful.
 */
@interface VDownloadOperation : NSOperation

@property (nonatomic, readonly) NSURL *url; ///< The URL being downloaded

/**
 Time to wait before retrying this download if it fails. This property actually
 has no effect on this operation, since this operation is not designed to
 retry. But calling code can feel free to use it for bookkeeping.
 */
@property (nonatomic) NSTimeInterval retryInterval;

/**
 Initializes a new instance of this class with the given url and completion block.
 
 NOTE: The completion block may not be called if the task is cancelled before it finishes.
 */
- (instancetype)initWithURL:(NSURL *)url completion:(VDownloadOperationCompletion)completionBlock;

@end