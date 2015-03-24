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

@end
