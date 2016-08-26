//
//  VUploadTaskCreator.h
//  victorious
//
//  Created by Josh Hinman on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VUploadManager, VUploadTaskInformation;

/**
 Creates a new VUploadTask object with the given
 form fields and file uploads.
 */
@interface VUploadTaskCreator : NSObject

/**
 The upload manager that was passed into the init method.
 */
@property (nonatomic, readonly) VUploadManager *uploadManager;

/**
 The request that will be used to create the upload task.
 */
@property (nonatomic, strong) NSURLRequest *request;

/**
 A dictionary of form fields to submit. The keys are
 the form field names, and should be NSStrings, and
 the values can be either NSNull, NSStrings, or
 NSURLs that point to local files. If NSNull, the
 field will be ignored.
 */
@property (nonatomic, strong) NSDictionary *formFields;

/**
 The preview image used to create the upload task.
 */
@property (nonatomic, strong) UIImage *previewImage;

/**
 The upload description used to create the upload task.
 */
@property (nonatomic, strong) NSString *uploadDescription;

/**
 A boolean that indicates if the content being uploaded is a GIF
 */
@property (nonatomic, assign) BOOL isGIF;

/**
 Creates a new VUploadTaskCreator instance
 
 @param uploadManager The instance of VUploadManager that will
 ultimately be responsible for uploading
 the task that we are creating.
 */
- (instancetype)initWithUploadManager:(VUploadManager *)uploadManager;

/**
 Creates an upload task object with the information stored
 in the receiver's properties. Any file URLs that have
 been provided can be safely deleted after this method
 returns--the information in those files has been copied
 into the upload task.
 
 @return a new VUploadTaskInformation object, or nil if an error occurred.
 */
- (VUploadTaskInformation *)createUploadTaskWithError:(NSError *__autoreleasing *)error;

@end
