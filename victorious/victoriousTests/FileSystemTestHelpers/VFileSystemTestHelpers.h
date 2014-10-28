//
//  VFileSystemTestHelpers.h
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VFileSystemTestHelpers : NSObject

+ (BOOL)fileExistsInCachesDirectoryWithLocalPath:(NSString *)localPath;

+ (NSUInteger)numberOfFilesAtPath:(NSString *)localPath;

+ (BOOL)deleteCachesDirectory:(NSString *)localPath;

@end
