//
//  VCreateSheetCollectionViewCell.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetCollectionViewCell.h"

@implementation VCreateSheetCollectionViewCell

#pragma mark - Helpers

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.itemLabel.alpha = highlighted ? 0.3f : 1.0f;
    self.iconImageView.alpha = highlighted ? 0.3f : 1.0f;
}

@end
