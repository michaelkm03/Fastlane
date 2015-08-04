//
//  VTemplateImage.m
//  victorious
//
//  Created by Josh Hinman on 6/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VJSONHelper.h"
#import "VTemplateImage.h"

NSString * const VTemplateImageURLKey = @"imageURL";
static NSString * const kScaleKey = @"scale";

@implementation VTemplateImage

- (instancetype)init
{
    return [self initWithImageURL:nil scale:nil];
}

- (instancetype)initWithImageURL:(NSURL *)imageURL scale:(NSNumber *)scale
{
    self = [super init];
    if (self != nil )
    {
        _imageURL = imageURL;
        _scale = scale;
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)imageJSON
{
    NSURL *imageURL = [NSURL URLWithString:imageJSON[VTemplateImageURLKey]];
    
    VJSONHelper *helper = [[VJSONHelper alloc] init];
    NSString *scaleString = imageJSON[kScaleKey];
    NSNumber *scale = [helper numberFromJSONValue:scaleString];
    
    return [self initWithImageURL:imageURL scale:scale];
}

+ (BOOL)isImageJSON:(NSDictionary *)imageJSON
{
    return imageJSON[VTemplateImageURLKey] != nil;
}

- (BOOL)isEqual:(id)object
{
    if ( ![object isKindOfClass:[VTemplateImage class]] )
    {
        return NO;
    }
    
    VTemplateImage *otherImage = (VTemplateImage *)object;
    return [otherImage.imageURL isEqual:self.imageURL] &&
           ([otherImage.scale isEqual:self.scale] ||
            (otherImage.scale == nil && self.scale == nil));
}

- (NSUInteger)hash
{
    NSUInteger const prime = 37;
    NSUInteger hash = prime + self.imageURL.hash;
    hash = prime * hash + self.scale.hash;
    return hash;
}

@end
