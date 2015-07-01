//
//  VDependencyManager+VKeyboardStyle.h
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VKeyboardStyleKey;

@interface VDependencyManager (VKeyboardStyle)

/**
 *  Returns an appropriate UIKeyboardAppearance for the given key. Defaults to light.
 */
- (UIKeyboardAppearance)keyboardStyleForKey:(NSString *)key;

@end
