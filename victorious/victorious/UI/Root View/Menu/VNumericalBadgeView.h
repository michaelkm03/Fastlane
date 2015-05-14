//
//  VNumericalBadgeView.h
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

enum
{
    VBadgeEmptyValue = NSIntegerMax ///< Displays an empty badge without any content
};

IB_DESIGNABLE

/**
 A label-like view for displaying
 a badge next to a menu item or
 in bar buttons.
 */
@interface VNumericalBadgeView : UIView

@property (nonatomic, strong) UIFont *font; ///< The font for display
@property (nonatomic, strong) IBInspectable UIColor *textColor; ///< The color of the number inside the circle
@property (nonatomic, strong, readonly) UIColor *defaultBadgeColor; ///< The iOS system style red color
@property (nonatomic) IBInspectable NSInteger badgeNumber; ///< The number to display

@end
