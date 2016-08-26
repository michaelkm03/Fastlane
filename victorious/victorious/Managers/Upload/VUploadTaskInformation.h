//
//  VUploadTaskInformation.h
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Stores information related to an ongoing upload task
 */
@interface VUploadTaskInformation : NSObject <NSSecureCoding>

/**
 The request object for the upload. The HTTPBody/HTTPBodyStream 
 properties of this request will be ignored (see the 
 bodyFileURL property)
 */
@property (nonatomic, readonly) NSURLRequest *request;

/**
 The name of the file that will be used as the body of
 the POST. The file should be stored in the directory
 returned by a call to -[VUploadManager urlForNewUploadBodyFile].
 */
@property (nonatomic, readonly) NSString *bodyFilename;

/**
 A preview of the data being uploaded
 */
@property (nonatomic, readonly) UIImage *previewImage;

/**
 A localized string that can be displayed
 to the user describing this upload.
 */
@property (nonatomic, readonly) NSString *uploadDescription;

/**
 A boolean that indicates if the content being uploaded is a GIF
*/
@property (nonatomic, readonly) BOOL isGif;

/**
 A unique identifier for this upload task
 */
@property (nonatomic, readonly) NSUUID *identifier;

/**
 The total number of bytes sent for this task.
 This value is NOT written to disk by encodeWithCoder: and will reset after unarchiving.
 */
@property (nonatomic, assign) int64_t bytesSent;

/**
 The expected number bytes to be sent to complete this task. 
 This value will be zero when a request is started.
 This value is NOT written to disk by encodeWithCoder: and will reset after unarchiving.
 */
@property (nonatomic, assign) int64_t expectedBytesToSend;

/**
 Creates a new instance of VUploadTaskInformation with the specified properties.
 */

- (instancetype)initWithRequest:(NSURLRequest *)request previewImage:(UIImage *)previewImage bodyFilename:(NSString *)bodyFilename description:(NSString *)uploadDescription isGif:(BOOL)isGif;


@end
