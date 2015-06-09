//
//  VDependencyManager+VHighlightContainer.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VHighlightContainer.h"
#import "UIView+AutoLayout.h"
#import <objc/runtime.h>

static const char kHighlightBackgroundKey;

@implementation VDependencyManager (VHighlightContainer)

- (void)addHighlightViewToHost:(id<VHighlightContainer>)highlightHost
{
    if (![highlightHost respondsToSelector:@selector(highlightContainerView)])
    {
        return;
    }
    
    UIView *containerView = [highlightHost highlightContainerView];
    
    if (containerView == nil)
    {
        return;
    }
    
    UIView *existingBackground = objc_getAssociatedObject(containerView, &kHighlightBackgroundKey);
    BOOL shouldShowHighlight = [[self numberForKey:kShowsHighlightedStateKey] boolValue];
    
    if (existingBackground == nil && shouldShowHighlight)
    {
        // Dimming view
        UIView *dimmingView = [UIView new];
        dimmingView.backgroundColor = [UIColor blackColor];
        dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [containerView addSubview:dimmingView];
        [containerView v_addFitToParentConstraintsToSubview:dimmingView];
        
        objc_setAssociatedObject(containerView, &kHighlightBackgroundKey, dimmingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else if (existingBackground != nil && !shouldShowHighlight)
    {
        [existingBackground removeFromSuperview];
        objc_setAssociatedObject(containerView, &kHighlightBackgroundKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
