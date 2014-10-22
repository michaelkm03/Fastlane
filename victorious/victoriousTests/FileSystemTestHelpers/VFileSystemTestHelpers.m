//
//  VFileSystemTestHelpers.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFileSystemTestHelpers.h"

@implementation VFileSystemTestHelpers

+ (BOOL)fileExistsInCachesDirectoryWithLocalPath:(NSString *)localPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths firstObject] stringByAppendingPathComponent:localPath];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSUInteger)numberOfFilesAtPath:(NSString *)localPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths firstObject] stringByAppendingPathComponent:localPath];
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil].count;
}

+ (BOOL)deleteCachesDirectory:(NSString *)localPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths firstObject] stringByAppendingPathComponent:localPath];
    NSError *error = nil;
    BOOL didSucceed = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    return didSucceed;
}

@end
