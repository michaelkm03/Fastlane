//
//  NSURL+TemporaryFiles.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+TemporaryFiles.h"

@implementation NSURL (TemporaryFiles)

+ (NSURL *)temporaryFileURLWithExtension:(NSString *)extension
{
    NSUUID *uuid = [NSUUID UUID];
    NSString *tempFilename = [[uuid UUIDString] stringByAppendingPathExtension:extension];
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempFilename]];
}

@end
