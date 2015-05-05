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

    [self addBackground:[self background]
        asSubviewOfView:[backgroundHost backgroundContainerView]];
}

- (void)addLoadingBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundContainer
{
    if (![backgroundContainer respondsToSelector:@selector(loadingBackgroundContainerView)])
    {
        return;
    }
    
    [self addBackground:[self loadingBackground]
        asSubviewOfView:[backgroundContainer loadingBackgroundContainerView]];
}

- (void)addBackground:(VBackground *)background
      asSubviewOfView:(UIView *)containerView
{
    if (background == nil)
    {
        return;
    }
    
    __block BOOL alreadyContainsBackground = NO;
    [containerView.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop)
     {
         if ([subView isKindOfClass:[VBackground class]])
         {
             alreadyContainsBackground = YES;
             *stop = YES;
         }
     }];
    
    if (!alreadyContainsBackground)
    {
        UIView *backgroundView = [background viewForBackground];
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:backgroundView];
        [containerView sendSubviewToBack:backgroundView];
        [containerView v_addFitToParentConstraintsToSubview:backgroundView];
    }
}

@end
