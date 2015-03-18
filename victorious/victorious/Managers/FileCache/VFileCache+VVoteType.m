//
//  VFileCache+VVoteType.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"
#import "VFileCache.h"
#import "VVoteType.h"

NSString * const VVoteTypeFilepathFormat     = @"com.getvictorious.vote_types/%@";
NSString * const VVoteTypeSpriteNameFormat   = @"sprite_%lu.png";
NSString * const VVoteTypeIconName           = @"icon.png";
NSString * const VVoteTypeIconLargeName      = @"icon-large.png";

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
}

#pragma mark - Saving images to disk

- (void)cacheImagesForVoteTypes:(NSArray *)voteTypes
{
    if ( voteTypes == nil || voteTypes.count == 0 )
    {
        return;
    }
    
    // Do single images first, they are higher priority
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
     {
         if ( [voteType isKindOfClass:[VVoteType class]] && voteType.containsRequiredData )
         {
             NSString *iconSavePath = [self savePathForImage:VVoteTypeIconName forVote:voteType];
             [self cacheFileAtUrl:voteType.iconImage withSavePath:iconSavePath];
             
             NSString *largeIconSavePath = [self savePathForImage:VVoteTypeIconLargeName forVote:voteType];
             [self cacheFileAtUrl:voteType.iconImageLarge withSavePath:largeIconSavePath];
         }
     }];
    
    // Now arrays (animation sequences), lower priority
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
     {
         if ( [voteType isKindOfClass:[VVoteType class]] && voteType.containsRequiredData )
         {
             NSArray *spriteImages = (NSArray *)voteType.images;
             NSArray *spriteSavePaths = [self savePathsForVoteTypeSprites:voteType];
             [self cacheFilesAtUrls:spriteImages withSavePaths:spriteSavePaths];
         }
     }];
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
                callback( [UIImage imageWithData:data] );
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
    NSData *data = [self getCachedFileForSavePath:iconSavePath];
    return [UIImage imageWithData:data];
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
    
    NSArray *dataArray = [self getCachedFilesForSavePaths:[self savePathsForVoteTypeSprites:voteType]];
    return [self imageArrayFromDataArray:dataArray];
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
    
    [self getCachedFilesForSavePaths:[self savePathsForVoteTypeSprites:voteType] completeCallback:^(NSArray *dataArray) {
        callback( [self imageArrayFromDataArray:dataArray] );
    }];
}

- (NSArray *)imageArrayFromDataArray:(NSArray *)dataArray
{
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    [dataArray enumerateObjectsUsingBlock:^(NSData *data, NSUInteger idx, BOOL *stop) {
        UIImage *image = [UIImage imageWithData:data];
        if ( image )
        {
            [imageArray addObject:image];
        }
    }];
    return [NSArray arrayWithArray:imageArray];
}

#pragma mark - Build Key Paths

- (NSString *)savePathForImage:(NSString *)imageName forVote:(VVoteType *)voteType
{
    NSString *localRootPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.voteTypeName];
    return [localRootPath stringByAppendingPathComponent:imageName];
}

- (NSString *)savePathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index
{
    NSString *localRootPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.voteTypeName];
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
