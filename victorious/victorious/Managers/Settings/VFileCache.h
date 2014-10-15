//
//  VFileCache.h
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VFileCache : NSObject

@property (nonatomic, readonly) dispatch_queue_t dispatchQueue;

@property (nonatomic, copy) NSData *(^encoderBlock)(NSData *);

@property (nonatomic, copy) id (^decoderBlock)(NSData *);

/**
 Save file to disk asychrnously.
 */
- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withKeyPath:(NSString *)keyPath;

/**
 Load a file asynchrononusly by keyPath.
 */
- (BOOL)getCachedFileForKeyPath:(NSString *)keyPath completeCallback:(void(^)(NSData *))completeCallback;

/**
 Load a file synchrononusly by keyPath.
 */
- (NSData *)getCachedFileForKeyPath:(NSString *)keyPath;

@end
