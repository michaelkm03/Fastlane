//
//  VDependencyManager+VBackground.h
//  victorious
//
//  Created by Michael Sena on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@class VBackground;

 /**
 *  A convenience category for quickly grabbing backgrounds.
 */
@interface VDependencyManager (VBackground)

/**
 *  A background or nil if unable to find one for the default background key.
 */
- (VBackground *)background;

/**
 *  A background to use in place of content while loading.
 */
- (VBackground *)loadingBackground;

/**
 *  A background for the specified key.
 */
- (VBackground *)backgroundForKey:(NSString *)key;

@end
