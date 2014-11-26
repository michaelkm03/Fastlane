//
//  VInboxBadgeView.h
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VHasManagedDependencies.h"

@class VDependencyManager;

/**
 A UILabel subclass designed for displaying
 a badge next to a menu item or in bar
 buttons.
 */
@interface VBadgeLabel : UILabel <VHasManagedDependancies>

/**
 An instance of VDependencyManager for supplying theme colors and fonts
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
