//
//  VCoachmarkManager.m
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmarkManager.h"
#import "VCoachmark.h"
#import "VCoachmarkView.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import <objc/runtime.h>

static NSString * const kCoachmarksKey = @"coachmarks";
static const CGFloat kAnimationDuration = 0.2f;
static const char kPassthroughViewKey;

@interface VCoachmarkManager () <VPassthroughContainerViewDelegate>

@property (nonatomic, strong) NSArray *coachmarks;

@end

@implementation VCoachmarkManager

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
#warning Populate with all coachmarks from user defaults
        _coachmarks = @[];
        
        NSArray *returnedCoachmarks = [dependencyManager arrayOfValuesOfType:[VCoachmark class] forKey:kCoachmarksKey];
        NSMutableArray *validCoachmarks = [[NSMutableArray alloc] init];
        for ( VCoachmark *coachmark in returnedCoachmarks )
        {
            NSInteger indexOfCoachmark = [_coachmarks indexOfObjectIdenticalTo:coachmark];
            if ( indexOfCoachmark != NSNotFound )
            {
                [validCoachmarks addObject:[_coachmarks objectAtIndex:indexOfCoachmark]];
                continue;
            }
            [validCoachmarks addObject:coachmark];
        }
        
        _coachmarks = [validCoachmarks copy];
    }
    return self;
}

- (void)displayCoachmarkViewInViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier
{
#warning Check for a coachmark that can be displayed by a screen with the provided identifier
    VCoachmark *coachmark = [self.coachmarks firstObject];
    
    VCoachmarkView *coachmarkView = [VCoachmarkView coachmarkViewWithCoachmark:coachmark
                                                                        center:CGPointZero
                                                                   targetPoint:CGPointZero];
    [self addCoachmarkView:coachmarkView toView:viewController.view];
}

- (void)hideCoachmarkViewInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    VPassthroughContainerView *passthroughContainer = objc_getAssociatedObject(viewController.view, &kPassthroughViewKey);
    [self removePassthroughContainerView:passthroughContainer animated:animated];
}

- (void)passthroughViewRecievedTouch:(VPassthroughContainerView *)passthroughContainerView
{
    [self removePassthroughContainerView:passthroughContainerView animated:YES];
}

- (void)removePassthroughContainerView:(VPassthroughContainerView *)passthroughContainerView animated:(BOOL)animated
{
    if ( passthroughContainerView != nil )
    {
        objc_setAssociatedObject(passthroughContainerView, &kPassthroughViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        passthroughContainerView.delegate = nil;
        passthroughContainerView.userInteractionEnabled = NO;
        [self animateOverlayView:passthroughContainerView
                       toVisible:NO
                        animated:animated
                  withCompletion:^(BOOL finished)
         {
             [passthroughContainerView removeFromSuperview];
         }];
    }
}

- (void)addCoachmarkView:(VCoachmarkView *)coachmarkView toView:(UIView *)view
{
    VPassthroughContainerView *passthroughOverlay = [[VPassthroughContainerView alloc] initWithFrame:view.bounds];
    passthroughOverlay.delegate = self;
    [passthroughOverlay addSubview:coachmarkView];
    passthroughOverlay.alpha = 0.0f;
    [view addSubview:passthroughOverlay];
    [self animateOverlayView:passthroughOverlay toVisible:YES animated:YES withCompletion:^(BOOL finished)
    {
        objc_setAssociatedObject(view, &kPassthroughViewKey, passthroughOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (void)animateOverlayView:(UIView *)overlayView
                 toVisible:(BOOL)visible
                  animated:(BOOL)animated
            withCompletion:(void (^)(BOOL))completion
{
    CGFloat targetAlpha = visible ? 1.0f : 0.0f;
    if ( animated )
    {
        [UIView animateWithDuration:kAnimationDuration
                         animations:^
         {
             overlayView.alpha = targetAlpha;
         }
                         completion:completion];
    }
    else
    {
        overlayView.alpha = targetAlpha;
    }
}

@end
