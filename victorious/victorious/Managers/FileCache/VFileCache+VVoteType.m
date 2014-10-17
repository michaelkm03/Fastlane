//
//  VFileCache+VVoteType.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"
#import "VFileCache.h"

NSString * const VVoteTypeFilepathFormat     = @"com.getvictorious.vote_types/%@";
NSString * const VVoteTypeSpriteNameFormat   = @"sprite_%lu.png";
NSString * const VVoteTypeIconName           = @"icon.png";
NSString * const VVoteTypeFlightImageName    = @"flight_image.png";

@implementation VFileCache (VVoteType)

- (BOOL)validateVoteType:(VVoteType *)voteType
{
    // TODO: Once all values are expected from the server, let CoreData and RestKit validate models
    BOOL isObjectValid = voteType != nil
        && [voteType isKindOfClass:[VVoteType class]]
        && voteType.name != nil
        && voteType.name.length > 0;
    
    if ( !isObjectValid )
    {
        return NO;
    }
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    __block BOOL areImagesValid = spriteImages.count > 0;
    [spriteImages enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger i, BOOL *stop)
     {
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
    if ( ![self validateVoteType:voteType] )
    {
        return NO;
    }
    
    [self setEncoder];
    
    NSString *iconKeyPath = [self keyPathForImage:VVoteTypeIconName forVote:voteType];
    [self cacheFileAtUrl:voteType.iconImage withKeyPath:iconKeyPath];
    
    NSString *flightImageKeyPath = [self keyPathForImage:VVoteTypeFlightImageName forVote:voteType];
    [self cacheFileAtUrl:voteType.iconImage withKeyPath:flightImageKeyPath];
    
    NSArray *spriteImages = (NSArray *)voteType.images;
    NSArray *spriteKeyPaths = [self keyPathsForVoteTypeSprites:voteType];
    [self cacheFilesAtUrls:spriteImages withKeyPaths:spriteKeyPaths];
    
    return YES;
}

#pragma mark - Retrieve Images

- (BOOL)getImageWithName:(NSString *)imageName forVoteType:(VVoteType *)voteType completionCallback:(void(^)(UIImage *))callback
{
    if ( ![self validateVoteType:voteType] || imageName == nil || imageName.length == 0 )
    {
        return NO;
    }
    
    [self setDecoder];
    
    NSString *iconKeyPath = [self keyPathForImage:imageName forVote:voteType];
    return [self getCachedFileForKeyPath:iconKeyPath completeCallback:^(NSData *data)
            {
                callback( (UIImage *)data );
            }];
}

- (UIImage *)getImageWithName:(NSString *)imageName forVoteType:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] || imageName == nil || imageName.length == 0 )
    {
        return nil;
    }
    
    [self setDecoder];
    
    NSString *iconKeyPath = [self keyPathForImage:imageName forVote:voteType];
    return (UIImage *)[self getCachedFileForKeyPath:iconKeyPath];
}

- (NSArray *)getSpriteImagesForVoteType:(VVoteType *)voteType
{
    if ( ![self validateVoteType:voteType] )
    {
        return nil;
    }
    
    [self setDecoder];
    
    return [self getCachedFilesForKeyPaths:[self keyPathsForVoteTypeSprites:voteType]];
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

- (NSString *)keyPathForImage:(NSString *)imageName forVote:(VVoteType *)voteType
{
    NSString *localRootPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.name];
    return [localRootPath stringByAppendingPathComponent:imageName];
}

- (NSString *)keyPathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index
{
    NSString *localRootPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.name];
    NSString *fileName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, (unsigned long)index];
    return [localRootPath stringByAppendingPathComponent:fileName];
}

- (NSArray *)keyPathsForVoteTypeSprites:(VVoteType *)voteType
{
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
