//
//  VSleekActionButton.h
//  victorious
//
//  Created by Patrick Lynch on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

/**
 *  VSleekActionButtons draw a colored circle behind an icon for the button.
 *  Tint color for image swaps between selected and unselected variants.
 */
@interface VSleekActionButton : UIButton

/**
 *  A tint color to represent the selected state.
 */
@property (nonatomic, copy) UIColor *selectedTintColor;

/**
 *  A tint color to represent the default (non-selected) state.
 */
@property (nonatomic, copy) UIColor *unselectedTintColor;

/**
 *  A color to be rendered in a circle in the background behind the image.
 */
@property (nonatomic, copy) UIColor *backgroundColor;

@end
