//
//  VFileCache.h
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger VFileCacheMaximumSaveFileRetries;

@interface VFileCache : NSObject

/**
 A block that can be set by calling code to provide any modifications to the data
 before it is written, e.g. wrapping it in UIImagePNGRepresentation()
 */
@property (nonatomic, copy) NSData *(^encoderBlock)(NSData *);

/**
 A block that can be set by calling code to provide any modifications to the data
 after it is read.
 */
@property (nonatomic, copy) id (^decoderBlock)(NSData *);

/**
 Save a singlefile to disk asychronously.  Overwrites any existing files.
 */
- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withSavePath:(NSString *)savePath;

/**
 Save a single file to disk asychronously.
 @param shouldOverwrite Determines whether or not to overwrite an existing file
 */
- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withSavePath:(NSString *)savePath shouldOverwrite:(BOOL)shouldOverwrite;

/**
 Save multiple files to disk asychronously.  Overwrites any existing files.
 */
- (BOOL)cacheFilesAtUrls:(NSArray *)fileUrls withSavePaths:(NSArray *)savePaths;

/**
 Save multiple files to disk asychronously.
 @param shouldOverwrite Determines whether or not to overwrite an existing file
 */
- (BOOL)cacheFilesAtUrls:(NSArray *)fileUrls withSavePaths:(NSArray *)savePaths shouldOverwrite:(BOOL)shouldOverwrite;

/**
 Load a single file synchrononusly by savePath.
 */
- (NSData *)getCachedFileForSavePath:(NSString *)savePath;

/**
 Loads multiple files by a keypath array asynchronously
 */
- (NSArray *)getCachedFilesForSavePaths:(NSArray *)savePaths;

/**
 Load a single file asynchrononusly by savePath.
 */
- (BOOL)getCachedFileForSavePath:(NSString *)savePath completeCallback:(void(^)(NSData *))completeCallback;

/**
 Load a single file asynchrononusly by savePath.
 */
- (BOOL)getCachedFilesForSavePaths:(NSArray *)savePaths completeCallback:(void(^)(NSArray *))completeCallback;

/**
 Checks if file exists at path.
 */
- (BOOL)fileExistsAtPath:(NSString *)filepath;

/**
 Creates an absolute path to the caches directory by prepending to the provided local path.
 */
- (NSString *)getCachesDirectoryPathForPath:(NSString *)path;

@end
