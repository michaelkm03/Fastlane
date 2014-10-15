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
NSString * const VFileCacheCachedSpriteNameFormat   = @"sprite_%lu.png";
NSString * const VFileCacheCachedIconName           = @"icon.png";

@implementation VFileCache (VoteType)

- (BOOL)validateVoteType:(VVoteType *)voteType
{
    BOOL isObjectValid = voteType != nil
        && [voteType isKindOfClass:[VVoteType class]]
        && voteType.icon != nil
        && voteType.icon.length > 0
        && voteType.name != nil
        && voteType.name.length > 0;
    
    if ( !isObjectValid )
    {
        return NO;
    }
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    __block BOOL areImagesValid = spriteImages.count > 0;
    [spriteImages enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop) {
        if ( imageUrl.length == 0 || ![imageUrl isKindOfClass:[NSString class]] )
        {
            areImagesValid = NO;
            *stop = YES;
        }
    }];
    
    return areImagesValid;
}

#pragma mark - Coders

- (void)setEncoder
{
    self.encoderBlock = ^NSData *(NSData *data) {
        return UIImagePNGRepresentation( [UIImage imageWithData:data] );
    };
}

- (void)setDecoder
{
    self.decoderBlock = ^id (NSData *data) {
        return [UIImage imageWithData:data];
    };
}

#pragma mark - Saving images to disk

- (BOOL)cacheImagesForVoteType:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] )
    {
        return NO;
    }
    
    [self setEncoder];
    
    NSString *iconKeyPath = [self keyPathForVoteTypeIcon:voteType];
    [self cacheFileAtUrl:voteType.icon withKeyPath:iconKeyPath];
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    NSArray *spriteKeyPaths = [self keyPathsForVoteTypeSprites:voteType];
    [self cacheFilesAtUrls:spriteImages withKeyPaths:spriteKeyPaths];
    
    return YES;
}

#pragma mark - Retrieve Images

- (void)getIconImageForVoteType:(VVoteType *)voteType completionCallback:(void(^)(NSArray *))callback
{
    if ( ![self validateVoteType:voteType] )
    {
        return;
    }
    
    [self setDecoder];
}

- (UIImage *)getIconImageForVoteType:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] )
    {
        return nil;
    }
    
    [self setDecoder];
    
    NSString *iconKeyPath = [self keyPathForVoteTypeIcon:voteType];
    return (UIImage *)[self getCachedFileForKeyPath:iconKeyPath];
}

- (NSArray *)getSpriteImagesForVoteType:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] )
    {
        return nil;
    }
    
    [self setDecoder];
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    return [self getCachedFilesForKeyPaths:spriteImages];
}

- (void)getSpriteImagesForVoteType:(VVoteType *)voteType completionCallback:(void(^)(NSArray *))callback
{
    if ( ![self validateVoteType:voteType] )
    {
        return;
    }
    
    [self setDecoder];
    
    [self getCachedFilesForKeyPaths:[self keyPathsForVoteTypeSprites:voteType] completeCallback:callback];
}

#pragma mark - Build Key Paths

- (NSString *)keyPathForVoteTypeIcon:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] )
    {
        return nil;
    }
    
    NSString *localRootPath = [NSString stringWithFormat:VFileCacheCachedFilepathFormat, voteType.name];
    return [localRootPath stringByAppendingPathComponent:VFileCacheCachedIconName];
}

- (NSString *)keyPathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index
{
    if ( ![self validateVoteType:voteType] )
    {
        return nil;
    }
    
    NSString *localRootPath = [NSString stringWithFormat:VFileCacheCachedFilepathFormat, voteType.name];
    NSString *fileName = [NSString stringWithFormat:VFileCacheCachedSpriteNameFormat, (unsigned long)index];
    return [localRootPath stringByAppendingPathComponent:fileName];
}

- (NSArray *)keyPathsForVoteTypeSprites:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] )
    {
        return nil;
    }
    
    __block NSMutableArray *containerArray = [[NSMutableArray alloc] init];
    NSArray *spriteImages = (NSArray *)voteType.images;
    [spriteImages enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop)
     {
         NSString *spriteKeyPath = [self keyPathForVoteTypeSprite:voteType atFrameIndex:i];
         if ( spriteKeyPath != nil )
         {
             [containerArray addObject:spriteKeyPath];
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
