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
 A URL to a file that will be used as the body of 
 the POST
 */
@property (nonatomic, readonly) NSURL *bodyFileURL;

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
 A unique identifier for this upload task
 */
@property (nonatomic, readonly) NSUUID *identifier;

/**
 Creates a new instance of VUploadTaskInformation with the specified properties.
 */
- (instancetype)initWithRequest:(NSURLRequest *)request previewImage:(UIImage *)previewImage bodyFileURL:(NSURL *)bodyFileURL description:(NSString *)uploadDescription;

@end
