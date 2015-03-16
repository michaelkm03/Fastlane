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

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    self.labelTitle.font = font;
}

- (void)setColor:(UIColor *)color withTitle:(NSString *)title
{
    self.colorSwatchView.backgroundColor = color;
    self.labelTitle.text = title;
}

@end
