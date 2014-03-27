//
//  VInboxBadgeView.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VBadgeLabel.h"

@implementation VBadgeLabel

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width += self.font.lineHeight;
    return size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

@end
