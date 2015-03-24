//
//  VHamburgerButton.h
//  victorious
//
//  Created by Josh Hinman on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

extern NSString * const VHamburgerButtonIconKey; ///< The key that identifies the menu icon in VDependencyManager

/**
 A hamburger button to be displayed in the navigation bar.
 Includes a numerical badge, too.
 */
@interface VHamburgerButton : UIView <VHasManagedDependencies>

@property (nonatomic) NSInteger badgeNumber; ///< The number to display in the badge

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager; ///< Loads a new instance of VHamburgerButton from a nib file

/**
 Adds a target/action for a particular event.
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
