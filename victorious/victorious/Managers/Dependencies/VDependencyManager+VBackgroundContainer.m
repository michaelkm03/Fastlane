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
#import <objc/runtime.h>

static const char kAssociatedBackgroundKey;

@implementation VDependencyManager (VBackgroundContainer)

- (void)addBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundHost
{
    [self addBackgroundToBackgroundHost:backgroundHost forKey:nil];
}

- (void)addBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundHost forKey:(NSString *)key
{
    if (![backgroundHost respondsToSelector:@selector(backgroundContainerView)])
    {
        return;
    }
    UIView *containerView = [backgroundHost backgroundContainerView];
    if (![self canAddBackgroundToBackgroundHost:containerView])
    {
        return;
    }
    
    VBackground *background = key == nil ? [self background] : [self backgroundForKey:key];
    [self addBackground:background asSubviewOfView:containerView];
}

- (void)addLoadingBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundContainer
{
    if (![backgroundContainer respondsToSelector:@selector(loadingBackgroundContainerView)])
    {
        return;
    }
    UIView *containerView = [backgroundContainer loadingBackgroundContainerView];
    if (![self canAddBackgroundToBackgroundHost:containerView])
    {
        return;
    }
    
    [self addBackground:[self loadingBackground]
        asSubviewOfView:containerView];
}

- (BOOL)canAddBackgroundToBackgroundHost:(UIView *)backgroundContainer
{
    return objc_getAssociatedObject(backgroundContainer, &kAssociatedBackgroundKey) == nil;
}

- (void)addBackground:(VBackground *)background
      asSubviewOfView:(UIView *)containerView
{
    if (containerView == nil)
    {
        return;
    }
    if (background == nil)
    {
        return;
    }
    
    UIView *backgroundView = [background viewForBackground];
    
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:backgroundView];
    [containerView sendSubviewToBack:backgroundView];
    [containerView v_addFitToParentConstraintsToSubview:backgroundView];
    objc_setAssociatedObject(containerView, &kAssociatedBackgroundKey, background, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
