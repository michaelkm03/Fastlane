//
//  VBasicToolPickerCell.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBasicToolPickerCell.h"

@implementation VBasicToolPickerCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.contentView.backgroundColor = selected ? [UIColor lightGrayColor] : [UIColor clearColor];
}

@end
