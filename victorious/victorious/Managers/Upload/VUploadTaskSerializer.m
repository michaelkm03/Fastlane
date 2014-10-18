//
//  VUploadTaskSerializer.m
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUploadTaskInformation.h"
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
    NSMutableArray *uploadTasks = nil;
    @try
    {
        NSArray *unfilteredUploadTasks = [NSKeyedUnarchiver unarchiveObjectWithFile:self.fileURL.path];
        uploadTasks = [[NSMutableArray alloc] initWithCapacity:unfilteredUploadTasks.count];
        for (VUploadTaskInformation *uploadTask in unfilteredUploadTasks)
        {
            // TODO
            if ([uploadTask isKindOfClass:[VUploadTaskInformation class]]) // && [[NSFileManager defaultManager] fileExistsAtPath:uploadTask.bodyFileURL.path])
            {
                [uploadTasks addObject:uploadTask];
            }
        }
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
