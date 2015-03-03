//
//  VDirectorySeeMoreItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VDirectorySeeMoreItemCell : VBaseCollectionViewCell

/**
 The border color of the cell, which should match the other cells in this row
 that are showing a stream or stream or streams.
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 The tint of the arrow image, which by default is white.
 */
@property (nonatomic, strong) UIColor *imageColor;

/**
 The primary text label indicating more content is available
 beyond what is displayed in the current row.
 */
@property (nonatomic, weak) IBOutlet UILabel *seeMoreLabel;

/**
 Allows calling code to update a constant that controls how far from the
 bottom edge of the cell's content view the background view extend.
 */
- (void)updateBottomConstraintToConstant:(CGFloat)constant;

@end
