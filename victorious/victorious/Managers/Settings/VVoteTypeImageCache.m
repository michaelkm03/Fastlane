//
//  VVoteTypeImageCache.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteTypeImageCache.h"
#import "VVoteType.h"

static NSString * const kCachedFilepathFormat               = @"com.getvictorious.vote_types/%@";
static NSString * const kCachedSpriteNameFormat             = @"sprite_%i.png";
static NSString * const kCachedIconName                     = @"icon.png";

static const char * const kDispatchQueueLabel               = "com.getvictorious.vote_types_dispatch_queue";

@interface VVoteTypeImageCache()

@property (nonatomic, readonly) dispatch_queue_t dispatchQueue;

@end

@implementation VVoteTypeImageCache

- (dispatch_queue_t)dispatchQueue
{
    static dispatch_queue_t dispatch_queue;
    static dispatch_once_t once_token;
    dispatch_once( &once_token, ^{
        dispatch_queue = dispatch_queue_create( kDispatchQueueLabel, DISPATCH_QUEUE_CONCURRENT );
    });
    return dispatch_queue;
}

- (void)cacheImagesForVoteType:(VVoteType *)voteType
{
    // This will create the directory fist so that each task on the queue isn't trying to do that
    [self createDirectoryAtPath:[self directoryForVoteType:voteType]];
    
    // Load the icon on the concurrent queue
    dispatch_async( self.dispatchQueue, ^{
        [self saveImage:voteType.icon toPath:[self iconPathForVoteType:voteType]];
    });
    
    // Load each sprite image on the concurrent queue
    NSArray *images = (NSArray *)voteType.images;
    [images enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop){
        
        dispatch_async( self.dispatchQueue, ^{
            [self saveImage:imageUrl toPath:[self spritePathForVoteType:voteType atIndex:i]];
        });
    }];
}

- (NSArray *)getCachedSpritesForVoteType:(VVoteType *)voteType
{
    __block NSMutableArray *loadedImages = nil;
    dispatch_barrier_sync( self.dispatchQueue, ^{
        NSArray *images = (NSArray *)voteType.images;
        [images enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop){
            
            UIImage *image = [UIImage imageWithContentsOfFile:[self spritePathForVoteType:voteType atIndex:i]];
            if ( image != nil )
            {
                [loadedImages addObject:image];
            }
            else
            {
                // If there's an error, don't allow an incomplete array of images to be returned
                [loadedImages removeAllObjects];
                *stop = YES;
            }
        }];
    });
    return [NSArray arrayWithArray:loadedImages];
}

- (void)getCachedSpritesForVoteType:(VVoteType *)voteType complete:(void(^)(NSArray *))callback
{
    dispatch_barrier_async( self.dispatchQueue, ^{
        NSMutableArray *loadedImages = nil;
        NSArray *images = (NSArray *)voteType.images;
        [images enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:[self spritePathForVoteType:voteType atIndex:i]];
            if ( image != nil )
            {
                [loadedImages addObject:image];
            }
            else
            {
                [self saveImage:imageUrl toPath:[self spritePathForVoteType:voteType atIndex:i]];
            }
        }];
        
        // Callback on the main thread with the loaded images
        if ( callback != nil )
        {
            dispatch_async( dispatch_get_main_queue(), ^{
                callback( [NSArray arrayWithArray:loadedImages] );
            });
        }
    });
}

- (UIImage *)getCachedIconForVoteType:(VVoteType *)voteType
{
    __block UIImage *image = nil;
    dispatch_barrier_sync( self.dispatchQueue, ^{
        image = [UIImage imageWithContentsOfFile:[self iconPathForVoteType:voteType]];
    });
    return image;
}

- (NSString *)directoryForVoteType:(VVoteType *)voteType
{
    NSString *localDirectoryPath = [NSString stringWithFormat:kCachedFilepathFormat, voteType.name];
    return [self getCachesDirectoryPathForPath:localDirectoryPath];
}

- (NSString *)iconPathForVoteType:(VVoteType *)voteType
{
    return [[self directoryForVoteType:voteType] stringByAppendingPathComponent:kCachedIconName];
}

- (NSString *)spritePathForVoteType:(VVoteType *)voteType atIndex:(NSUInteger)index
{
    return [[self directoryForVoteType:voteType] stringByAppendingPathComponent:[NSString stringWithFormat:kCachedSpriteNameFormat, index]];
}

- (BOOL)saveImage:(NSString *)imageUrl toPath:(NSString *)filepath
{
    // Error checking
    if ( imageUrl == nil || imageUrl.length == 0 )
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
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    NSData *imageData = UIImagePNGRepresentation( [UIImage imageWithData:data] );
    
    // Write to disk
    NSError *error;
    BOOL didSucceed = [imageData writeToFile:filepath options:NSDataWritingAtomic error:&error];
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
    
    BOOL isDirectory;
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:compoundPath isDirectory:&isDirectory];
    if ( !doesFileExist || !isDirectory )
    {
        if ( ![self createDirectoryAtPath:compoundPath] )
        {
            return nil;
        }
    }
    return compoundPath;
}

- (BOOL)createDirectoryAtPath:(NSString *)path
{
    NSError *error;
    BOOL didCreateDirectory = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                        withIntermediateDirectories:YES
                                                                         attributes:nil
                                                                              error:&error];
    return didCreateDirectory;
}

@end
