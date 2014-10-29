//
//  VCollectionRefreshControl.m
//  victorious
//
//  Created by Will Long on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCollectionRefreshControl.h"

@implementation VCollectionRefreshControl
{
    BOOL topContentInsetSaved;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;

    CGFloat topInset = scrollView.contentInset.top;
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = scrollView.contentOffset.y + self.topOffset + topInset;
    self.frame = newFrame;
}

@end
