//
//  VScrollPaginator.m
//  victorious
//
//  Created by Patrick Lynch on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VScrollPaginator.h"

@interface VScrollPaginator()

@property (nonatomic, assign) CGPoint previousContentOffset;
@property (nonatomic, assign) BOOL hasScrolledOnce;
@property (nonatomic, assign, readwrite) BOOL isUserScrolling;

@end

@implementation VScrollPaginator

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( !self.isUserScrolling || self.delegate == nil)
    {
        return;
    }
    
    if ( self.hasScrolledOnce )
    {
        [self calculate:scrollView];
    }
    
    self.previousContentOffset = scrollView.contentOffset;
    self.hasScrolledOnce = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Only if the user started the scroll with a drag do we mark this YES
    self.isUserScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // As soon as a scroll initializted by a user or not comes to a stop
    // self.isUserScrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // As soon as the user lifts his/her finger
    self.isUserScrolling = NO;
}

- (void)calculate:(UIScrollView *)scrollView
{
    const CGFloat contentHeight = scrollView.contentSize.height;
    if (contentHeight <= scrollView.bounds.size.height)
    {
        return;
    }
    
    const CGFloat visibleHeight = CGRectGetHeight(scrollView.frame) - scrollView.contentInset.bottom;
    const CGFloat maxContentOffset = contentHeight - (visibleHeight * 2);
    const CGFloat minContentOffset = visibleHeight;
    const CGFloat scrollPositionY = scrollView.contentOffset.y;
    const BOOL isScrollingDown = self.previousContentOffset.y <= scrollView.contentOffset.y;
    
    if ( scrollPositionY >= maxContentOffset && isScrollingDown )
    {
        if ( [self.delegate respondsToSelector:@selector(shouldLoadNextPage)] )
        {
            [self.delegate shouldLoadNextPage];
        }
    }
    else if ( scrollPositionY < minContentOffset && !isScrollingDown )
    {
        if ( [self.delegate respondsToSelector:@selector(shouldLoadPreviousPage)] )
        {
            [self.delegate shouldLoadPreviousPage];
        }
    }
}

@end
