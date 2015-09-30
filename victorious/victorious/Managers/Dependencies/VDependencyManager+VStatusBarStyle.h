//
//  VDependencyManager+VStatusBarStyle.h
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@interface VDependencyManager (VStatusBarStyle)

/**
 *  Returns an appropriate UIStatusBarStyle for a given key. With an appropriate default.
 */
- (UIStatusBarStyle)statusBarStyleForKey:(NSString *)key;
/**
 * Returns an appropriate UIStatusBarStyle based on the illuminance a color
 * @param color the color used to determine status bar style
 */
- (UIStatusBarStyle)statusBarStyleForColor:(UIColor *)color;

@end
