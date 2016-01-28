//
//  VScrollPaginator.m
//  victorious
//
//  Created by Patrick Lynch on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VScrollPaginator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation VScrollPaginator

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( self.delegate == nil )
    {
        return;
    }
    
    const CGFloat contentHeight = scrollView.contentSize.height;
    const CGFloat visibleHeight = CGRectGetHeight(scrollView.frame) - scrollView.contentInset.bottom;
    const CGFloat maxContentOffset = contentHeight - (visibleHeight * 2);
    const CGFloat minContentOffset = visibleHeight;
    const CGFloat scrollPositionY = scrollView.contentOffset.y;
    
    if ( scrollPositionY >= maxContentOffset )
    {
        if ( [self.delegate respondsToSelector:@selector(shouldLoadNextPage)] )
        {
            [self.delegate shouldLoadNextPage];
        }
    }
    else if ( scrollPositionY < minContentOffset )
    {
        if ( [self.delegate respondsToSelector:@selector(shouldLoadPreviousPage)] )
        {
            [self.delegate shouldLoadPreviousPage];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
