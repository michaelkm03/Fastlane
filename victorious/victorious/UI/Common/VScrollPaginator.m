//
//  VScrollPaginator.m
//  victorious
//
//  Created by Patrick Lynch on 1/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VScrollPaginator.h"

#define LOG_PAGINATION_EVENTS 0
#if LOG_PAGINATION_EVENTS
#warning VScrollPaginator is logging pagination events.  Please turn this off before merging.
#endif

@implementation VScrollPaginator

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( self.delegate == nil )
    {
        return;
    }
    
    const CGFloat visibleHeight = CGRectGetHeight(scrollView.frame) - scrollView.contentInset.bottom;
    const CGFloat maxContentOffset = scrollView.contentSize.height - visibleHeight - visibleHeight;
    const CGFloat minContentOffset = visibleHeight;
    const CGFloat scrollPositionY = scrollView.contentOffset.y;
    
    if ( scrollPositionY >= maxContentOffset )
    {
#if LOG_PAGINATION_EVENTS
        VLog( @"shouldLoadNextPage :: delegate = (%@)", NSStringFromClass( [self.delegate class] ) );
#endif
        if ( [self.delegate respondsToSelector:@selector(shouldLoadNextPage)] )
        {
            [self.delegate shouldLoadNextPage];
        }
    }
    else if ( scrollPositionY < minContentOffset )
    {
#if LOG_PAGINATION_EVENTS
        VLog( @"shouldLoadPreviousPage :: delegate = (%@)", NSStringFromClass( [self.delegate class] ) );
#endif
        if ( [self.delegate respondsToSelector:@selector(shouldLoadPreviousPage)] )
        {
            [self.delegate shouldLoadPreviousPage];
        }
    }
}

@end
