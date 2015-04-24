//
//  VColorOptionCell.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VColorOptionCell.h"

@interface VColorOptionCell ()

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UIView *colorSwatchView;

@end

@implementation VColorOptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.colorSwatchView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    self.labelTitle.font = font;
}

- (void)setColor:(UIColor *)color withTitle:(NSString *)title
{
    if ( color == nil )
    {
        self.colorSwatchView.backgroundColor = [UIColor clearColor];
        self.colorSwatchView.layer.borderWidth = 1.0f;
    }
    else
    {
        self.colorSwatchView.backgroundColor = color;
        self.colorSwatchView.layer.borderWidth = 0.0f;
    }
    
    self.labelTitle.text = title;
}

@end
