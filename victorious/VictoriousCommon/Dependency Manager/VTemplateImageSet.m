//
//  VTemplateImageSet.m
//  victorious
//
//  Created by Josh Hinman on 6/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VTemplateImageSet.h"
#import "VTemplateImage.h"

static NSString * const kImageSetKey = @"imageSet";

@implementation VTemplateImageSet

- (instancetype)init
{
    return [self initWithImages:@[]];
}

- (instancetype)initWithImages:(NSArray *)images
{
    self = [super init];
    if ( self != nil )
    {
        NSMutableArray *sortedImages = [images mutableCopy];
        [sortedImages sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(scale)) ascending:NO] ]];
        _images = [sortedImages copy];
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)imageSetJSON
{
    NSArray *imageDictionaries = imageSetJSON[kImageSetKey];
    if ( [imageDictionaries isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:imageDictionaries.count];
        for (NSDictionary *imageDictionary in imageDictionaries)
        {
            if ( [imageDictionary isKindOfClass:[NSDictionary class]] )
            {
                if ( [VTemplateImage isImageJSON:imageDictionary] )
                {
                    VTemplateImage *image = [[VTemplateImage alloc] initWithJSON:imageDictionary];
                    [images addObject:image];
                }
            }
        }
        return [self initWithImages:images];
    }
    else
    {
        return [self init];
    }
}

+ (BOOL)isImageSetJSON:(NSDictionary *)imageSetJSON
{
    return imageSetJSON[kImageSetKey] != nil;
}

- (NSSet *)allImageURLs
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:self.images.count];
    for (VTemplateImage *image in self.images)
    {
        NSURL *imageURL = image.imageURL;
        if ( imageURL != nil )
        {
            [set addObject:imageURL];
        }
    }
    return set;
}

- (VTemplateImage *)imageForScreenScale:(CGFloat)scale
{
    VTemplateImage *returnValue = nil;
    for (VTemplateImage *image in self.images)
    {
        if ( returnValue == nil || image.scale.VCGFLOAT_VALUE >= scale )
        {
            returnValue = image;
        }
    }
    return returnValue;
}

@end
