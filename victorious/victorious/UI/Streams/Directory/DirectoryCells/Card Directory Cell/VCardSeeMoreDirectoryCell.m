//
//  VCardSeeMoreDirectoryCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCardSeeMoreDirectoryCell.h"
#import "VExtendedView.h"

static const CGFloat kBorderWidth = 0.5f;

@interface VCardSeeMoreDirectoryCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstriant;
@property (nonatomic, weak) IBOutlet VExtendedView *extendedView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation VCardSeeMoreDirectoryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self.extendedView setBackgroundColor:backgroundColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self.extendedView setBorderColor:_borderColor];
    [self.extendedView setBorderWidth:kBorderWidth];
}

- (void)setImageColor:(UIColor *)imageColor
{
    _imageColor = imageColor;
    
    UIImage *image = self.imageView.image;
    self.imageView.tintColor = _imageColor;
    self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
