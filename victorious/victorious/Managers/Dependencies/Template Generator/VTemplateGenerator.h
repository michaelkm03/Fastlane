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
 Initializes the template generator with the given init data.
 
 @param initData the return from the /api/init server call
 */
- (instancetype)initWithInitData:(NSDictionary *)initData;

/**
 Returns a configuration dictionary, suitable for passing to the init method on VDependencyManager
 */
- (NSDictionary *)configurationDict;

@end
