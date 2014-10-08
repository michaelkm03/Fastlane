//
//  VUploadTaskSerializer.h
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Writes/reads upload information to/from disk
 */
@interface VUploadTaskSerializer : NSObject

@property (nonatomic, readonly) NSURL *fileURL; ///< The file URL passed into the init method

/**
 Creates an instance of VUploadTaskSerializer
 
 @param fileURL URL to a file where task information will be read from/written to
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL;

/**
 Returns an array of upload tasks previously saved to disk
 */
- (NSArray /* VUploadTaskInformation */ *)uploadTasksFromDisk;

/**
 Saves an array of upload tasks to disk
 
 @return YES if successful
 */
- (BOOL)saveUploadTasks:(NSArray /* VUploadTaskInformation */ *)tasks;

@end
