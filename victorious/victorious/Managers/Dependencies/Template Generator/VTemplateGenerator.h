//
//  VTemplateGenerator.h
//  victorious
//
//  Created by Josh Hinman on 11/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Generates template information for VDependencyManager
 */
@interface VTemplateGenerator : NSObject

/**
 Returns a template dictionary for VDependencyManager
 with the given init data
 
 @param initData a JSON object retrieved from the /api/init call
 */
+ (NSDictionary *)templateWithInitData:(NSDictionary *)initData;

@end
