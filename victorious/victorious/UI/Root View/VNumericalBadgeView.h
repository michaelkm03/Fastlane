//
//  VNumericalBadgeView.h
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

/**
 A label-like view for displaying
 a badge next to a menu item or
 in bar buttons.
 */
@interface VNumericalBadgeView : UIView

@property (nonatomic, strong) UIFont *font; ///< The font for display

/**
 Sets the number displayed
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber;

@end
