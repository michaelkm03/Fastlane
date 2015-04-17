//
//  VTextPostImageHelper.m
//  victorious
//
//  Created by Patrick Lynch on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostImageHelper.h"
#import "UIImage+VTint.h"

static const CGFloat kTintedBackgroundImageAlpha            = 0.375f;
static const CGBlendMode kTintedBackgroundImageBlendMode    = kCGBlendModeLuminosity;

@interface VTextPostImageHelper()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation VTextPostImageHelper

- (void)exportWithAssetAtURL:(NSURL *)assetURL color:(UIColor *)color completion:(void(^)(NSURL *, NSError *))completion
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       NSString *path = [self assetExportPath];
                       
                       UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:assetURL]];
                       if ( image != nil )
                       {
                           UIImage *tintentImage = [self tintedImageWithImage:image color:color];
                           NSData *imageData = UIImageJPEGRepresentation( tintentImage, 1 );
                           NSError *error;
                           BOOL success = [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
                           dispatch_async( dispatch_get_main_queue(), ^
                                          {
                                              NSString *fileURLPath = [NSString stringWithFormat:@"file://%@", path];
                                              NSURL *outputURL = [NSURL URLWithString:fileURLPath];
                                              completion( success ? outputURL : nil, error );
                                          });
                           return;
                       }
                       
                       dispatch_async( dispatch_get_main_queue(), ^
                                      {
                                          NSString *domain = @"Invalid `assetURL` parameter.";
                                          NSError *error = [NSError errorWithDomain:domain code:-1 userInfo:nil];
                                          completion( nil, error );
                                      });
                       
                   });

}

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
        UIImage *tintentImage = [self tintedImageWithImage:image color:color];
        dispatch_async( dispatch_get_main_queue(), ^
                       {
                           [self.cache setObject:tintentImage forKey:color];
                           completion( tintentImage );
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

#pragma mark - Private helpers

- (NSString *)assetExportPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd_HH:mm:ss";
    NSString *imageName = [NSString stringWithFormat:@"fuck.jpg", [dateFormatter stringFromDate:[NSDate date]]];
    NSArray *cachePathes = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    return [cachePathes.firstObject stringByAppendingPathComponent:imageName];
}

- (UIImage *)tintedImageWithImage:(UIImage *)image color:(UIColor *)color
{
    return [image v_tintedImageWithColor:color
                                   alpha:kTintedBackgroundImageAlpha
                               blendMode:kTintedBackgroundImageBlendMode];
}

@end
