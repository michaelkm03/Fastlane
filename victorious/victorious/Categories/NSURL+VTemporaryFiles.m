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
    
    NSError *error = nil;
    NSURL *urlForDirectory = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), directory]];
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:urlForDirectory
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    if (success)
    {
        return [NSURL fileURLWithPath:[urlForDirectory.absoluteString stringByAppendingString:tempFilename]];
    }
    else
    {
        return nil;
    }
}

@end
