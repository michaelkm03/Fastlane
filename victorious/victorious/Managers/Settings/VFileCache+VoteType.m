//
//  VFileCache+VoteType.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"
#import "VFileCache.h"

NSString * const VFileCacheCachedFilepathFormat     = @"com.getvictorious.vote_types/%@";
NSString * const VFileCacheCachedSpriteNameFormat   = @"sprite_%i.png";
NSString * const VFileCacheCachedIconName           = @"icon.png";

@implementation VFileCache (VoteType)

- (void)setCoders
{
    self.encoderBlock = ^NSData *(NSData *data) {
        return UIImagePNGRepresentation( [UIImage imageWithData:data] );
    };
    
    self.decoderBlock = ^id (NSData *data) {
        return [UIImage imageWithData:data];
    };
}

- (void)cacheImagesForVoteType:(VVoteType *)voteType
{
    [self setCoders];
    
    NSString *iconKeyPath = [self keyPathForVoteTypeIcon:voteType];
    [self cacheFileAtUrl:voteType.icon withKeyPath:iconKeyPath];
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    [spriteImages enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop)
    {
        NSString *spriteKeyPath = [self keyPathForVoteTypeSprite:voteType atFrameIndex:i];
        [self cacheFileAtUrl:voteType.icon withKeyPath:spriteKeyPath];
    }];
}

#pragma mark - Retrieve Images

- (void)getIconImageForVoteType:(VVoteType *)voteType completionCallback:(void(^)(UIImage *))callback
{
    dispatch_barrier_async( self.dispatchQueue, ^{
        UIImage *image = [self getIconImageForVoteType:voteType];
        dispatch_async( dispatch_get_main_queue(), ^{
            callback( image );
        });
    });
}

- (UIImage *)getIconImageForVoteType:(VVoteType *)voteType
{
    [self setCoders];
    
    NSString *iconKeyPath = [self keyPathForVoteTypeIcon:voteType];
    return (UIImage *)[self getCachedFileForKeyPath:iconKeyPath];
}

- (void)getSpriteImagesForVoteType:(VVoteType *)voteType completionCallback:(void(^)(NSArray *))callback
{
    dispatch_barrier_async( self.dispatchQueue, ^{
        NSArray *images = [self getSpriteImagesForVoteType:voteType];
        dispatch_async( dispatch_get_main_queue(), ^{
            callback( images );
        });
    });
}

- (NSArray *)getSpriteImagesForVoteType:(VVoteType *)voteType
{
    [self setCoders];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *spriteImages = (NSArray *)voteType.images;
    [spriteImages enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop)
     {
         NSString *spriteKeyPath = [self keyPathForVoteTypeSprite:voteType atFrameIndex:i];
         UIImage *image = (UIImage *)[self getCachedFileForKeyPath:spriteKeyPath];
         if ( image == nil )
         {
             // In the event of an error, don't allow an incomplete array to be returned
             [mutableArray removeAllObjects];
             *stop = YES;
         }
         else
         {
             [mutableArray addObject:image];
         }
     }];
    return [NSArray arrayWithArray:mutableArray];
}

#pragma mark - Build Key Paths

- (NSString *)keyPathForVoteTypeIcon:(VVoteType *)voteType
{
    NSString *localRootPath = [NSString stringWithFormat:VFileCacheCachedFilepathFormat, voteType.name];
    return [localRootPath stringByAppendingPathComponent:VFileCacheCachedIconName];
}

- (NSString *)keyPathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index
{
    NSString *localRootPath = [NSString stringWithFormat:VFileCacheCachedFilepathFormat, voteType.name];
    NSString *fileName = [NSString stringWithFormat:VFileCacheCachedSpriteNameFormat, index];
    return [localRootPath stringByAppendingPathComponent:fileName];
}

@end
