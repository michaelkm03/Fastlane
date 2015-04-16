//
//  VEditableTextPostImageHelper.m
//  victorious
//
//  Created by Patrick Lynch on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditableTextPostImageHelper.h"
#import "UIImage+VTint.h"

static const CGFloat kTintedBackgroundImageAlpha            = 0.375f;
static const CGBlendMode kTintedBackgroundImageBlendMode    = kCGBlendModeLuminosity;

@interface VEditableTextPostImageHelper()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation VEditableTextPostImageHelper

- (UIImage *)imageWithImage:(UIImage *)image color:(UIColor *)color
{
    if ( color == nil || image == nil )
    {
        return image;
    }
    
    NSParameterAssert( [color isKindOfClass:[UIColor class]] );
    NSParameterAssert( [image isKindOfClass:[UIImage class]] );
    
    UIImage *cachedImage = [self.cache objectForKey:color];
    if ( cachedImage != nil )
    {
        return cachedImage;
    }
    
    UIImage *output = [image v_tintedImageWithColor:color
                                              alpha:kTintedBackgroundImageAlpha
                                          blendMode:kTintedBackgroundImageBlendMode];
    [self.cache setObject:output forKey:color];
    
    return output;
}

#pragma mark - Image cache

- (void)clearCache
{
    self.cache = nil;
}

- (NSCache *)cache
{
    if ( _cache == nil )
    {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}

@end
