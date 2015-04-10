//
//  VHashtagOptionCell.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

/**
 A collection view cell that displays a color selection option for some purpose.
 */
@interface VHashtagOptionCell : VBaseCollectionViewCell

/**
 The name of the color.
 */
@property (nonatomic, copy) NSString *title;

/**
 A `UIColor` object that this collection view cell represents.
 */
@property (nonatomic, strong) UIColor *selectedColor;

/**
 The font used to display the title text.  Use this property to set
 the font as desired when configuring this cell.
 */
@property (nonatomic, copy) UIFont *font;

@end
