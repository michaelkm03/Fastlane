//
//  NSURL+VTemporaryFiles.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VTemporaryFiles.h"

@implementation NSURL (VTemporaryFiles)

+ (NSURL *)v_temporaryFileURLWithExtension:(NSString *)extension inDirectory:(NSString *)directory
{
    NSParameterAssert(directory != nil);
    
    NSUUID *uuid = [NSUUID UUID];
    NSString *tempFilename;
    
    if (extension != nil)
    {
        tempFilename = [[uuid UUIDString] stringByAppendingPathExtension:extension];
    }
    else
    {
        tempFilename = [uuid UUIDString];
    }
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:directory] isDirectory:YES];
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:tempFilename];
    
    if (success)
    {
        return fileURL;
    }
    else
    {
        return nil;
    }
}

@end
