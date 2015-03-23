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
 *  It maintains tab bar items and their badging. It sums all of the tab bar item badges 
 *  and assigns to the applications shared badge number.
 */
@interface VTabMenuShim : NSObject <VHasManagedDependancies>

/**
 *  An array of VNavigationDestinationContainerViewController wrapping the 
 *  navigation destinations of the items property for this menu.
 */
- (NSArray *)wrappedNavigationDesinations;

/**
 *  Called when a tabbar controller is about to navigate to a view controller
 *  at the selected index.
 */
- (void)willNavigateToIndex:(NSInteger)index;

/**
 *  A Background to use for this tab menu.
 */
@property (nonatomic, readonly) VBackground *background;

@end
