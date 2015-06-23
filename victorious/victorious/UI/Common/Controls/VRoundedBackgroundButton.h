//
//  VRoundedBackgroundButton.h
//  victorious
//
//  Created by Michael Sena on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"

/**
 *  VRoundedBackgroundButtons draw a colored circle behind an icon for the button.
 *  Color swaps between selected and unselected variants.
 */
@interface VRoundedBackgroundButton : UIButton

/**
 *  A color representing the selected state.
 */
@property (nonatomic, copy) UIColor *selectedColor;

/**
 *  A color representing the unselected state.
 */
@property (nonatomic, copy) UIColor *unselectedColor;

@property (nonatomic, weak) id associatedObjectForButton;

/**
 *  A tint color to represent the active state.
 */
@property (nonatomic, copy) UIColor *activeTintColor;

/**
 *  A tint color to represent the default (non-active) state.
 */
@property (nonatomic, copy) UIColor *inactiveTintColor;

/**
 The default image to show for the active state.
 */
@property (nonatomic, strong) UIImage *activeImage;

/**
 The default image to show for unselected and inactive state.
 */
@property (nonatomic, strong) UIImage *inactiveImage;

/**
 Uses the the activeImage and activeTintColor properties to update the appearance
 of the button
 */
@property (nonatomic, assign, getter=isActive) BOOL active;

@end
