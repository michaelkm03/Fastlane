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

- (void)renderImage:(UIImage *)image color:(UIColor *)color completion:(void(^)(UIImage *))completion
{
    NSParameterAssert( completion != nil );
    
    if ( color == nil || image == nil )
    {
        completion( image );
        return;
    }
    
    NSParameterAssert( [color isKindOfClass:[UIColor class]] );
    NSParameterAssert( [image isKindOfClass:[UIImage class]] );
    
    UIImage *cachedImage = [self.cache objectForKey:color];
    if ( cachedImage != nil )
    {
        completion(  cachedImage );
        return;
    }
    
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        UIImage *output = [image v_tintedImageWithColor:color
                                                  alpha:kTintedBackgroundImageAlpha
                                              blendMode:kTintedBackgroundImageBlendMode];
        
        dispatch_async( dispatch_get_main_queue(), ^
                       {
                           [self.cache setObject:output forKey:color];
                           completion( output );
                       });
    });
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
