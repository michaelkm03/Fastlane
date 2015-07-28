//
//  VTemplateImageSet.h
//  victorious
//
//  Created by Josh Hinman on 6/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VTemplateImage;

/**
 An image set is an array containing multiple versions of the same image
 at different scales. This class parses an image set from template JSON
 and determines which image should be used based on the current screen
 scale.
 
 For more information, see the "image set" data type in the template
 specification.
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

NS_ASSUME_NONNULL_END
