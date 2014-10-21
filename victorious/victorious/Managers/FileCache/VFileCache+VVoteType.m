//
//  VFileCache+VVoteType.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"
#import "VFileCache.h"
#import "VVoteType+ImageSerialization.h"

NSString * const VVoteTypeFilepathFormat     = @"com.getvictorious.vote_types/%@";
NSString * const VVoteTypeSpriteNameFormat   = @"sprite_%lu.png";
NSString * const VVoteTypeIconName           = @"icon.png";

@implementation VFileCache (VVoteType)

#pragma mark - Coders

- (void)setEncoder
{
    self.encoderBlock = ^NSData *(NSData *data)
    {
        return UIImagePNGRepresentation( [UIImage imageWithData:data] );
    };
}

- (void)setDecoder
{
    self.decoderBlock = ^id (NSData *data)
    {
        return [UIImage imageWithData:data];
    };
}

#pragma mark - Saving images to disk

- (BOOL)cacheImagesForVoteType:(VVoteType *)voteType
{
    if ( !voteType.containsRequiredData )
    {
        return NO;
    }
    
    [self setEncoder];
    
    NSString *iconSavePath = [self savePathForImage:VVoteTypeIconName forVote:voteType];
    [self cacheFileAtUrl:voteType.iconImage withSavePath:iconSavePath];
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    NSArray *spriteSavePaths = [self savePathsForVoteTypeSprites:voteType];
    [self cacheFilesAtUrls:spriteImages withSavePaths:spriteSavePaths];
    
    return YES;
}

#pragma mark - Retrieve Images

- (BOOL)getImageWithName:(NSString *)imageName forVoteType:(VVoteType *)voteType completionCallback:(void(^)(UIImage *))callback
{
    if ( !voteType.containsRequiredData || imageName == nil || imageName.length == 0 )
    {
        return NO;
    }
    
    [self setDecoder];
    
    NSString *iconSavePath = [self savePathForImage:imageName forVote:voteType];
    return [self getCachedFileForSavePath:iconSavePath completeCallback:^(NSData *data)
            {
                callback( (UIImage *)data );
            }];
}

- (UIImage *)getImageWithName:(NSString *)imageName forVoteType:(VVoteType *)voteType
{
    if ( !voteType.containsRequiredData || imageName == nil || imageName.length == 0 )
    {
        return nil;
    }
    
    [self setDecoder];
    
    NSString *iconSavePath = [self savePathForImage:imageName forVote:voteType];
    return (UIImage *)[self getCachedFileForSavePath:iconSavePath];
}

- (BOOL)isImageCached:(NSString *)imageName forVoteType:(VVoteType *)voteType
{
    return [self fileExistsAtPath:[self getCachesDirectoryPathForPath:[self savePathForImage:imageName forVote:voteType]]];
}

- (NSArray *)getSpriteImagesForVoteType:(VVoteType *)voteType
{
    if ( !voteType.containsRequiredData )
    {
        return nil;
    }
    
    [self setDecoder];
    
    return [self getCachedFilesForSavePaths:[self savePathsForVoteTypeSprites:voteType]];
}

- (BOOL)areSpriteImagesCachedForVoteType:(VVoteType *)voteType
{
    __block BOOL allFilesExist = YES;
    NSArray *filePaths = [self savePathsForVoteTypeSprites:voteType];
    [filePaths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop)
    {
        if ( ![self fileExistsAtPath:[self getCachesDirectoryPathForPath:path]] )
        {
            allFilesExist = NO;
            *stop = YES;
        }
    }];
    return allFilesExist;
}

- (void)getSpriteImagesForVoteType:(VVoteType *)voteType completionCallback:(void(^)(NSArray *))callback
{
    if ( !voteType.containsRequiredData )
    {
        return;
    }
    
    [self setDecoder];
    
    [self getCachedFilesForSavePaths:[self savePathsForVoteTypeSprites:voteType] completeCallback:callback];
}

#pragma mark - Build Key Paths

- (NSString *)savePathForImage:(NSString *)imageName forVote:(VVoteType *)voteType
{
    NSString *localRootPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.name];
    return [localRootPath stringByAppendingPathComponent:imageName];
}

- (NSString *)savePathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index
{
    NSString *localRootPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.name];
    NSString *fileName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, (unsigned long)index];
    return [localRootPath stringByAppendingPathComponent:fileName];
}

- (NSArray *)savePathsForVoteTypeSprites:(VVoteType *)voteType
{
    __block NSMutableArray *containerArray = [[NSMutableArray alloc] init];
    NSArray *spriteImages = (NSArray *)voteType.images;
    [spriteImages enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop)
     {
         NSString *spriteSavePath = [self savePathForVoteTypeSprite:voteType atFrameIndex:i];
         if ( spriteSavePath != nil )
         {
             [containerArray addObject:spriteSavePath];
         }
         else
         {
             // Return nil so that calling code knows ther was an error
             // isntead of continuing with missing keypaths
             containerArray = nil;
             *stop = YES;
         }
     }];
    
    if ( containerArray == nil )
    {
        return nil;
    }
    
    return [NSArray arrayWithArray:containerArray];
}

@end
