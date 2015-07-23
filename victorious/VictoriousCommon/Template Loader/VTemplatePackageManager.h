//
//  VTemplatePackageManager.h
//  victorious
//
//  Created by Josh Hinman on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class analyzes a template JSON payload to find references
 to other URLs that must also be downloaded before a template
 can be considered complete.
 */
@interface VTemplatePackageManager : NSObject

@property (nonatomic, readonly) NSDictionary *templateJSON; ///< The template passed into the init method

/**
 Initializes a new instance of VTemplateAssociatedData 
 with a specific template file.
 */
- (instancetype)initWithTemplateJSON:(NSDictionary *)templateJSON NS_DESIGNATED_INITIALIZER;

/**
 Returns a set of NSURL objects pointing to other items 
 (e.g. images) that must also be downloaded as part of
 this template.
 */
- (NSSet *)referencedURLs;

/**
 Returns a set of NSString objects for each URL scheme that
 the package manager considers to be valid. URLs appearing
 in the template that contain a scheme not in this set will
 not be included in the `referencedURLs` property.
 */
+ (NSSet *)validSchemes;

@end
