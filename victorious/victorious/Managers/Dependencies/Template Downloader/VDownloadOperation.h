//
//  VDownloadOperation.h
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This block is called when the URL has been
 successfully downloaded. No need for a
 bool to indicate success, or an error 
 property, because this class just keeps 
 retrying until it's successful!
 
 @param downloadedFile location on disk of the file that's been downloaded. It will
                       be stored in a temporary location, so it should be moved
                       somewhere more permanent immediately.
 */
typedef void (^VDownloadOperationCompletion)(NSURL *downloadedFile);

/**
 An NSOperation subclass to download a single 
 file, with retries until it's successful.
 */
@interface VDownloadOperation : NSOperation

@property (nonatomic, readonly) NSURL *url; ///< The URL being downloaded
@property (nonatomic) NSTimeInterval retryInterval; ///< The time between the first and second attempts. Third attempt and onward use an increasingly larger interval.

/**
 Initializes a new instance of this class with the given url and completion block.
 
 NOTE: The completion block will not be called if the task is cancelled before it's complete.
 */
- (instancetype)initWithURL:(NSURL *)url completion:(VDownloadOperationCompletion)completionBlock;

@end
