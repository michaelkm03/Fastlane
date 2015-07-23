//
//  VTemplateImageSet.h
//  victorious
//
//  Created by Josh Hinman on 6/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VTemplateImage;

/**
 An image set that appears in a template
 */
@interface VTemplateImageSet : NSObject

/**
 Initializes a new instance of VTemplateImageSet
 with a snippet of JSON from a template.
 */
- (instancetype)initWithJSON:(NSDictionary *)imageSetJSON NS_DESIGNATED_INITIALIZER;

/**
 Returns YES for an input that looks like an image
 set. Does not guarantee that the input is 100% 
 valid, only that it contains a key that suggests
 it is an image set and not some other template
 data type.
 
 Returns NO for JSON objects that don't appear to
 be image sets.
 */
+ (BOOL)isImageSetJSON:(NSDictionary *)imageSetJSON;

/**
 Returns a set of NSURL objects representing
 all the imageURLs in this image set.
 */
- (NSSet *)allImageURLs;

/**
 Returns the image from this set that is
 appropriate for a given screen scale.
 */
- (VTemplateImage *)imageForScreenScale:(CGFloat)scale;

@end
