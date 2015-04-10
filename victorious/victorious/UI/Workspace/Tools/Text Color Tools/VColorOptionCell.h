//
//  VColorOptionCell.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

/**
 A collection view cell to be displayed in a picker view that displays
 a color option, including a small swatch of the color along with the
 color's name/title.
 */
@interface VColorOptionCell : VBaseCollectionViewCell

/**
 The font to be used to display the color's title.  Set the desired
 font using this property during cell configuration.
 */
@property (nonatomic, copy) UIFont *font;

/**
 Configure the cell to use `color` for its swatch view and `title` for its
 text view that indicates the name of the color to be shown to the user.
 */
- (void)setColor:(UIColor *)color withTitle:(NSString *)title;

@end
