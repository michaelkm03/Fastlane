//
//  VHashtagOptionCell.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagOptionCell.h"

@interface VHashtagOptionCell()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@end

@implementation VHashtagOptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.labelTitle.text = title;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    self.labelTitle.font = font;
}

@end
