//
//  VTemplateImageMacro.m
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VJSONHelper.h"
#import "VTemplateImage.h"
#import "VTemplateImageMacro.h"
#import "VSDKURLMacroReplacement.h"

static NSString * const kImageCountKey = @"imageCount";
static NSString * const kImageMacroKey = @"imageMacro";
static NSString * const kScaleKey = @"scale";
static NSString * const kMacroReplacement = @"XXXXX";

@implementation VTemplateImageMacro

- (instancetype)init
{
    return [self initWithJSON:@{ }];
}

- (instancetype)initWithJSON:(NSDictionary *)imageMacroJSON
{
    self = [super init];
    if ( self != nil )
    {
        VJSONHelper *helper = [[VJSONHelper alloc] init];
        NSNumber *imageCount = [helper numberFromJSONValue:imageMacroJSON[kImageCountKey]];
        NSNumber *scale = [helper numberFromJSONValue:imageMacroJSON[kScaleKey]];
        NSString *macro = imageMacroJSON[kImageMacroKey];
        
        if ( imageCount != nil && [macro isKindOfClass:[NSString class]] )
        {
            NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:[imageCount unsignedIntegerValue]];
            VSDKURLMacroReplacement *macroReplacement = [[VSDKURLMacroReplacement alloc] init];
            for (NSUInteger n = 0; n < [imageCount unsignedIntegerValue]; n++)
            {
                NSString *macroReplacementString = [NSString stringWithFormat:@"%.5lu", (unsigned long)n];
                NSString *url = [macroReplacement urlByReplacingMacrosFromDictionary:@{ kMacroReplacement: macroReplacementString}
                                                                         inURLString:macro];
                VTemplateImage *image = [[VTemplateImage alloc] initWithImageURL:[NSURL URLWithString:url] scale:scale];
                [images addObject:image];
            }
            _images = [images copy];
        }
        else
        {
            _images = @[];
        }
    }
    return self;
}

+ (BOOL)isImageMacroJSON:(NSDictionary *)imageMacroJSON
{
    return imageMacroJSON[kImageMacroKey] != nil;
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

@end
