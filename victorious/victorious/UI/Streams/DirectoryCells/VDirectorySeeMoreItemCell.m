//
//  VDirectorySeeMoreItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectorySeeMoreItemCell.h"
#import "VExtendedView.h"

@interface VDirectorySeeMoreItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstriant;
@property (nonatomic, weak) IBOutlet VExtendedView *extendedView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation VDirectorySeeMoreItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateBottomConstraintToConstant:(CGFloat)constant
{
    if ( self.bottomConstriant.constant != constant )
    {
        self.bottomConstriant.constant = constant;
        [self layoutIfNeeded];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self.extendedView setBackgroundColor:backgroundColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self.extendedView setBorderColor:_borderColor];
}

- (void)setImageColor:(UIColor *)imageColor
{
    _imageColor = imageColor;
    
    UIImage *image = self.imageView.image;
    self.imageView.tintColor = _imageColor;
    self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
