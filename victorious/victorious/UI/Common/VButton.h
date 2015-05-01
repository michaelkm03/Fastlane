//
//  VButton.h
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 These styles, when assigned to the `style` property of VButton, will
 select different drawing styles and redraw the button accordingly.
 */
typedef NS_ENUM( NSInteger, VButtonStyle )
{
    /**
     Colors, borders and other visual attributes will be unchanged, as in 
     a normal UIBUtton.  Use this value if you just want to show the scaling
     animations.
     */
    VButtonStyleNone,
    
    /**
     A solid background color, colored by `primaryColor`,
     with white text and rounded corners.  This style indicates
     a primary action, such as `submit` on a form.
     */
    VButtonStylePrimary,
    
    /** 
     A clear background color and gray stroke and text.  This style indicates
     a secondary action, such as `cancel` on a form.
     */
    VButtonStyleSecondary
};

/**
 A button that handles custom drawing according to its style property.
 */
@interface VButton : UIButton

/**
 Sets the style according to the specified value and redraws right away.
 */
@property (nonatomic, assign) VButtonStyle style;

/**
 A color used for display according to the configured `style` property.
 @see `VButtonStyle` enum for emments explaining uses.
 */
@property (nonatomic) UIColor *primaryColor;

/**
 A color used for display according to the configured `style` property.
 @see `VButtonStyle` enum for emments explaining uses.
 */
@property (nonatomic) UIColor *secondaryColor;

/**
 The corner radius of the button
 */
@property (nonatomic) CGFloat cornerRadius;

/**
 Shoes the text and shows an activity indicator centered in the button to
 represent a loading state.
 */
- (void)showActivityIndicator;

/**
 Hides the activity indicator, if visible, and shows the title text of the button
 with whatever text was last set.
 */
- (void)hideActivityIndicator;

@end
