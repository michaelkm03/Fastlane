//
//  VTemplateImageSet.m
//  victorious
//
//  Created by Josh Hinman on 6/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VDependencyManager.h"
#import "VTemplateImageSet.h"
#import "VTemplateImage.h"

static NSString * const kImageSetKey = @"imageSet";

@interface VTemplateImageSet ()

@property (nonatomic, readonly) NSArray *images;

@end

@implementation VTemplateImageSet

- (instancetype)initWithJSON:(NSDictionary *)imageSetJSON
{
    self = [super init];
    if ( self != nil )
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
            [images sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(scale)) ascending:NO] ]];
            _images = [images copy];
        }
        else
        {
            _images = @[];
        }
    }
    return self;
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
