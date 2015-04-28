//
//  VHashtagOptionCell.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagOptionCell.h"

static NSString * const kCheckImageName = @"hashtag_option_check";

@interface VHashtagOptionCell()

@property (strong, nonatomic) UIImage *checkImage;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *checkBox; //< This is a button, but it is never enabled, just for show

@end

@implementation VHashtagOptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.checkBox.layer.cornerRadius = CGRectGetMidX( self.checkBox.bounds );
    
    self.checkImage = [UIImage imageNamed:kCheckImageName];
    
    self.selected = NO;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    
    [self updateSelectedState];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.labelTitle.text = title;
    
    [self updateSelectedState];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.labelTitle.font = font;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self updateSelectedState];
}

- (void)updateSelectedState
{
    if ( self.selected )
    {
        self.checkBox.layer.borderWidth = 0.0f;
        self.checkBox.layer.borderColor = [UIColor clearColor].CGColor;
        self.checkBox.backgroundColor = self.selectedColor;
        [self.checkBox setImage:self.checkImage forState:UIControlStateNormal];
    }
    else
    {
        self.checkBox.layer.borderWidth = 1.0f;
        self.checkBox.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
        self.checkBox.backgroundColor = [UIColor clearColor];
        [self.checkBox setImage:nil forState:UIControlStateNormal];
    }
    
    [self setNeedsDisplay];
}

@end
