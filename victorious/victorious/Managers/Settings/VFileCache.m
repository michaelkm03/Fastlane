//
//  VFileCache.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFileCache.h"

static const char * const kDispatchQueueLabel = "com.getvictorious.vote_types_dispatch_queue";

@implementation VFileCache

- (dispatch_queue_t)dispatchQueue
{
    static dispatch_queue_t dispatch_queue;
    static dispatch_once_t once_token;
    dispatch_once( &once_token, ^{
        dispatch_queue = dispatch_queue_create( kDispatchQueueLabel, DISPATCH_QUEUE_CONCURRENT );
    });
    return dispatch_queue;
}

- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withKeyPath:(NSString *)keyPath
{
    return [self cacheFileAtUrl:fileUrl withKeyPath:keyPath shouldOverwrite:NO];
}

- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withKeyPath:(NSString *)keyPath shouldOverwrite:(BOOL)shouldOverwrite
{
    // Error checking
    if ( fileUrl == nil || keyPath.length == 0 )
    {
        return NO;
    }
    if ( keyPath == nil || keyPath.length == 0 )
    {
        return NO;
    }
    
    dispatch_barrier_async( self.dispatchQueue, ^{
        
        // Creates directory (if it doesn't exist already)
        NSString *localDirectoryPath = [keyPath stringByDeletingLastPathComponent];
        [self createDirectoryAtPath:[self getCachesDirectoryPathForPath:localDirectoryPath]];
        
        NSString *fullPath = [self getCachesDirectoryPathForPath:keyPath];
        [self saveFile:fileUrl toPath:fullPath];
    });
    
    return YES;
}

- (BOOL)getCachedFileForKeyPath:(NSString *)keyPath completeCallback:(void(^)(NSData *))completeCallback
{
    if ( completeCallback == nil )
    {
        return NO;
    }
    
    dispatch_async( self.dispatchQueue, ^{
        
        // Load the data on this queue using synchronous method
        NSData *fileData = [self readFileForKeyPath:keyPath];
        
        // Response on the main queue
        dispatch_async( dispatch_get_main_queue(), ^{
            completeCallback( fileData );
        });
    });
    
    return YES;
}

- (NSData *)getCachedFileForKeyPath:(NSString *)keyPath
{
    if ( keyPath == nil || keyPath.length == 0 )
    {
        return nil;
    }
    
    __block NSData *fileData = nil;
    dispatch_sync( self.dispatchQueue, ^{
        fileData = [self readFileForKeyPath:keyPath];
    });
    return fileData;
}

- (NSData *)readFileForKeyPath:(NSString *)keyPath
{
    NSString *filepath = [self getCachesDirectoryPathForPath:keyPath];
    
    // Load the image from disk
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfFile:filepath options:0 error:&error];
    return fileData;
}

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath
{
    // Error checking
    if ( fileUrl == nil || fileUrl.length == 0 )
    {
        return NO;
    }
    if ( filepath == nil || filepath.length == 0 )
    {
        return NO;
    }
    
    // Check if file already exists
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
    BOOL isValidFile = [self fileSizeAtPath:filepath];
    if ( doesFileExist && isValidFile )
    {
        return YES;
    }
    
    // Download the image data
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]];
    
    // Allow an encoder block to modify the data and return it
    if ( self.encoderBlock != nil )
    {
        data = self.encoderBlock( data );
    }
    
    // Write to disk
    NSError *error;
    BOOL didSucceed = [data writeToFile:filepath options:NSDataWritingAtomic error:&error];
    if ( !didSucceed )
    {
        VLog( @"Error writing image to path:\n%@\n%@", filepath, [error localizedDescription] );
    }
    return didSucceed;
}

- (NSUInteger)fileSizeAtPath:(NSString *)path
{
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
   return (NSUInteger)[attributes fileSize];
}

- (NSString *)getCachesDirectoryPathForPath:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    NSString *compoundPath = [cachePath stringByAppendingPathComponent:path];
    return compoundPath;
}

- (BOOL)createDirectoryAtPath:(NSString *)path
{
    // Check if it exists already
    BOOL isDirectory = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory )
    {
        return YES;
    }
    else
    {
        // Create it
        NSError *error;
        BOOL didCreateDirectory = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        return didCreateDirectory;
    }
}

@end
