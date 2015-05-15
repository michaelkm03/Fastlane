//
//  VDependencyManager+VDefaultTemplate.h
//  victorious
//
//  Created by Josh Hinman on 4/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@interface VDependencyManager (VDefaultTemplate)

/**
 Returns a dependency manager guaranteed to return sensible default values
 for all color and font keys listed in VDependencyManager.h
 */
+ (VDependencyManager *)dependencyManagerWithDefaultValuesForColorsAndFonts;

@end
