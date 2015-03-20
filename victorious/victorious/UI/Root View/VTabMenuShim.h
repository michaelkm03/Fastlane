//
//  VTabMenuShim.h
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VBackground;

/**
 *  VTabMenuShim is used in conjunction with UITabBarController as a menu component.
 */
@interface VTabMenuShim : NSObject <VHasManagedDependancies>

/**
 *  An array of VNavigationDestinationContainerViewController wrapping the 
 *  navigation destinations of the items property for this menu.
 */
- (NSArray *)wrappedNavigationDesinations;

/**
 *  A Background to use for this tab menu.
 */
@property (nonatomic, readonly) VBackground *background;

@end
