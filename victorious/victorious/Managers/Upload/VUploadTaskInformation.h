//
//  VUploadTaskInformation.h
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Stores information related to an ongoing upload task
 */
@interface VUploadTaskInformation : NSObject <NSSecureCoding>

/**
 The request object for the upload. The HTTPBody/HTTPBodyStream 
 properties of this request will be ignored (see the 
 bodyFileURL property)
 */
@property (nonatomic, copy) NSURLRequest *request;

/**
 A URL to a file that will be used as the body of 
 the POST
 */
@property (nonatomic, strong) NSURL *bodyFileURL;

/**
 A localized string that can be displayed
 to the user describing this upload.
 */
@property (nonatomic, copy) NSString *uploadDescription;

@end
