//
//  VUploadTaskSerializer.m
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUploadTaskSerializer.h"

@implementation VUploadTaskSerializer

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self)
    {
        _fileURL = fileURL;
    }
    return self;
}

- (NSArray *)uploadTasksFromDisk
{
    NSArray *uploadTasks = nil;
    @try
    {
        uploadTasks = [NSKeyedUnarchiver unarchiveObjectWithFile:self.fileURL.path];
    }
    @catch (NSException *exception)
    {
        VLog(@"Unable to read upload tasks: %@", [exception reason]);
    }
    
    return uploadTasks;
}

- (BOOL)saveUploadTasks:(NSArray *)tasks
{
    return [NSKeyedArchiver archiveRootObject:tasks toFile:self.fileURL.path];
}

@end
