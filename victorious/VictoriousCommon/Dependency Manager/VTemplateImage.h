//
//  VTemplateImage.h
//  victorious
//
//  Created by Josh Hinman on 6/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VTemplateImageURLKey; ///< The JSON key that identifes the URL of a template image.

/**
 An image that appears in a template
 */
@interface VTemplateImage : NSObject

@property (nonatomic, readonly) NSURL *imageURL; ///< The image's URL
@property (nonatomic, readonly) NSNumber *scale; ///< The scale factor for the image

/**
 Initializes a new VTemplateImage instance with the given imageURL and scale.
 */
- (instancetype)initWithImageURL:(NSURL *)imageURL scale:(NSNumber *)scale NS_DESIGNATED_INITIALIZER;

/**
 Initializes a new VTemplateImage instance
 using a snippet of JSON from a template.
 */
- (instancetype)initWithJSON:(NSDictionary *)imageJSON;

/**
 Returns YES for an input that looks like an
 image. Does not guarantee that the input is
 100% valid, only that it contains a key that
 suggests it is an image and not some other
 template data type.
 
 Returns NO for JSON objects that
 don't appear to be images.
 */
+ (BOOL)isImageJSON:(NSDictionary *)imageJSON;

@end
