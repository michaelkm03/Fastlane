//
//  VFileCache.h
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withKeyPath:(NSString *)keyPath;

/**
 Save a single file to disk asychronously.
 @param shouldOverwrite Determines whether or not to overwrite an existing file
 */
- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withKeyPath:(NSString *)keyPath shouldOverwrite:(BOOL)shouldOverwrite;

/**
 Save multiple files to disk asychronously.  Overwrites any existing files.
 */
- (BOOL)cacheFilesAtUrls:(NSArray *)fileUrls withKeyPaths:(NSArray *)keyPaths;

/**
 Save multiple files to disk asychronously.
 @param shouldOverwrite Determines whether or not to overwrite an existing file
 */
- (BOOL)cacheFilesAtUrls:(NSArray *)fileUrls withKeyPaths:(NSArray *)keyPaths shouldOverwrite:(BOOL)shouldOverwrite;

/**
 Load a single file synchrononusly by keyPath.
 */
- (NSData *)getCachedFileForKeyPath:(NSString *)keyPath;

/**
 Loads multiple files by a keypath array asynchronously
 */
- (NSArray *)getCachedFilesForKeyPaths:(NSArray *)keyPaths;

/**
 Load a single file asynchrononusly by keyPath.
 */
- (BOOL)getCachedFileForKeyPath:(NSString *)keyPath completeCallback:(void(^)(NSData *))completeCallback;

/**
 Load a single file asynchrononusly by keyPath.
 */
- (BOOL)getCachedFilesForKeyPaths:(NSArray *)keyPaths completeCallback:(void(^)(NSArray *))completeCallback;

@end
