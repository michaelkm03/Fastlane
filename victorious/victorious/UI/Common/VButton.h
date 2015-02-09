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

@property (nonatomic, strong) UIColor *primaryColor;

@property (nonatomic, strong) UIColor *secondaryColor;

+ (UIColor *)defaultSecondaryColor;

- (void)showActivityIndicator;

- (void)hideActivityIndicator;

@end
