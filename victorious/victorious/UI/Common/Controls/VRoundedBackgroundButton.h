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

@property (nonatomic, weak) id associatedObjectForButton;

/**
 *  A tint color to represent the selected state.
 */
@property (nonatomic, copy) UIColor *selectedTintColor;

/**
 *  A tint color to represent the default (non-selected) state.
 */
@property (nonatomic, copy) UIColor *unselectedTintColor;

@end
