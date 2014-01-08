//
//  VInboxBadgeView.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VInboxBadgeLabel.h"

@implementation VInboxBadgeLabel

- (CGSize)intrinsicContentSize{
    CGSize size = [super intrinsicContentSize];
    size.width += self.font.lineHeight;
    return size;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
}

@end
