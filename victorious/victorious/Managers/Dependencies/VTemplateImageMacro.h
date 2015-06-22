//
//  VTemplateImageMacro.h
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 An array of macro'd images that appears in a template
 */
@interface VTemplateImageMacro : NSObject

/**
 Initializes a new instance of VTemplateImageMacro
 with a snippet of JSON from a template.
 */
- (instancetype)initWithJSON:(NSDictionary *)imageMacroJSON NS_DESIGNATED_INITIALIZER;

/**
 Returns YES for an input that looks like an image
 macro. Does not guarantee that the input is 100%
 valid, only that it contains a key that suggests
 it is an image macro and not some other template
 data type.
 
 Returns NO for JSON objects that don't appear to
 be image macros.
 */
+ (BOOL)isImageMacroJSON:(NSDictionary *)imageMacroJSON;

/**
 Returns an array of VTemplateImage objects created
 from the JSON passed into the initWithJSON: method
 */
- (NSArray *)images;

/**
 Returns a set of NSURL objects representing
 all the imageURLs in this image macro.
 */
- (NSSet *)allImageURLs;

@end
