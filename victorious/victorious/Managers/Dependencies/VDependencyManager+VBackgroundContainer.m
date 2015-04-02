//
//  VDependencyManager+VBackgroundContainer.m
//  victorious
//
//  Created by Michael Sena on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VBackground.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"

@implementation VDependencyManager (VBackgroundContainer)

- (void)addBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundHost
{
    if (![backgroundHost respondsToSelector:@selector(backgroundContainerView)])
    {
        return;
    }
    
    VBackground *background = [self background];
    if (background == nil)
    {
        return;
    }
    
    // We've already added a background do nothing
    if ([backgroundHost backgroundContainerView].subviews.count > 0)
    {
        return;
    }
    
    UIView *backgroundView = [background viewForBackground];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [[backgroundHost backgroundContainerView] addSubview:backgroundView];
    [[backgroundHost backgroundContainerView] v_addFitToParentConstraintsToSubview:backgroundView];
}

@end