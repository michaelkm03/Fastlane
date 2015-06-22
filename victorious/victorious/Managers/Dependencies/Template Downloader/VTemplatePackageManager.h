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

@end
