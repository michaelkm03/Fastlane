//
//  VDependencyManager+VBackgroundHost.m
//  victorious
//
//  Created by Michael Sena on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VBackgroundHost.h"
#import "VDependencyManager+VBackground.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"

@implementation VDependencyManager (VBackgroundHost)

- (void)addBackgroundToBackgroundHost:(id <VBackgroundHost>)backgroundHost
{
    if (![backgroundHost respondsToSelector:@selector(v_backgroundHost)])
    {
        return;
    }
    
    VBackground *background = [self background];
    if (background == nil)
    {
        return;
    }
    
    // We've already added a background do nothing
    if ([backgroundHost v_backgroundHost].subviews.count > 0)
    {
        return;
    }
    
    UIView *backgroundView = [background viewForBackground];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [[backgroundHost v_backgroundHost] addSubview:backgroundView];
    [[backgroundHost v_backgroundHost] v_addFitToParentConstraintsToSubview:backgroundView];
}

@end
