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
#import "VCoachmarkDisplayResponder.h"
#import "VNavigationController.h"
#import "UIViewController+VLayoutInsets.h"
#import "VTimerManager.h"

#define CLEAR_SHOWN_COACHMARKS 1

static NSString * const kShownCoachmarksKey = @"shownCoachmarks";
static NSString * const kReturnedCoachmarksKey = @"coachmarks";
static NSString * const kPassthroughContainerViewKey = @"passthroughContainerView";
static const CGFloat kAnimationDuration = 0.2f;
static const char kPassthroughViewKey;
static const CGFloat kCoachmarkHorizontalInset = 24;
static const CGFloat kCoachmarkVerticalInset = 5;

@interface VCoachmarkManager () <VPassthroughContainerViewDelegate>

@property (nonatomic, strong) NSArray *coachmarks;
@property (nonatomic, strong) NSMutableArray *hideTimers;

@end

@implementation VCoachmarkManager

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        
#if CLEAR_SHOWN_COACHMARKS
#warning CLEARING SHOWN COACHMARKS
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kShownCoachmarksKey];
#endif
        
        NSArray *shownCoachmarkIds = [[NSUserDefaults standardUserDefaults] objectForKey:kShownCoachmarksKey];
        NSArray *returnedCoachmarks = [dependencyManager arrayOfValuesOfType:[VCoachmark class] forKey:kReturnedCoachmarksKey];
        NSMutableArray *validCoachmarks = [[NSMutableArray alloc] init];
        for ( VCoachmark *coachmark in returnedCoachmarks )
        {
            if ( ![shownCoachmarkIds containsObject:coachmark.remoteId] )
            {
                //We haven't already shown this coachmark, add it to our new coachmarks array
                [validCoachmarks addObject:coachmark];
            }
        }
        
        _coachmarks = [validCoachmarks copy];
        [self saveShownStateOfCoachmarks];
    }
    return self;
}

- (void)displayCoachmarkViewInViewController:(UIViewController <VCoachmarkDisplayer> *)viewController
{
    NSString *identifier = [viewController screenIdentifier];
    VCoachmark *applicableCoachmark = nil;
    for ( VCoachmark *coachmark in self.coachmarks )
    {
        if ( !coachmark.hasBeenShown && [coachmark.displayScreens containsObject:identifier] )
        {
            applicableCoachmark = coachmark;
            break;
        }
    }
    
    if ( applicableCoachmark != nil )
    {
        CGFloat maxWidth = CGRectGetWidth(viewController.view.bounds) - kCoachmarkHorizontalInset * 2;
        if ( [applicableCoachmark.displayTarget isEqualToString:identifier] )
        {
            //Displaying as a toast
            VCoachmarkView *coachmarkView = [VCoachmarkView toastCoachmarkViewWithCoachmark:applicableCoachmark andMaxWidth:maxWidth];
            coachmarkView.frame = [self frameForToastCoachmarkViewWithSize:coachmarkView.frame.size andToastLocation:coachmarkView.coachmark.toastLocation inViewController:viewController];
            [self addCoachmarkView:coachmarkView toViewController:viewController];
        }
        else
        {
            UIResponder <VCoachmarkDisplayResponder> *nextResponder = [viewController targetForAction:@selector(findOnScreenMenuItemWithIdentifier:andCompletion:) withSender:self];
            if ( nextResponder == nil )
            {
                NSAssert(false, @"Need a responder for findOnScreenMenuItemWithIdentifier:andCompletion:");
                return;
            }
            
            [nextResponder findOnScreenMenuItemWithIdentifier:applicableCoachmark.displayTarget andCompletion:^(BOOL found, CGRect location)
            {
                if ( found )
                {
                    CGFloat arrowCenter = CGRectGetMidX(location) - kCoachmarkHorizontalInset;
                    CGFloat viewHeight = CGRectGetHeight(viewController.view.bounds) - [viewController v_layoutInsets].top;
                    VCoachmarkArrowDirection direction = CGRectGetMidY(location) > viewHeight / 2 ? VCoachmarkArrowDirectionDown : VCoachmarkArrowDirectionUp;
                    VCoachmarkView *coachmarkView = [VCoachmarkView tooltipCoachmarkViewWithCoachmark:applicableCoachmark
                                                                                             maxWidth:maxWidth
                                                                                arrowHorizontalOffset:arrowCenter
                                                                                    andArrowDirection:direction];
                    coachmarkView.frame = [self frameForTooltipCoachmarkViewWithSize:coachmarkView.frame.size
                                                                      arrowDirection:direction
                                                                   andTargetLocation:location
                                                                    inViewController:viewController];
                    [self addCoachmarkView:coachmarkView toViewController:viewController];
                }
            }];
        }
    }
}

- (void)hideCoachmarkViewInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    VPassthroughContainerView *passthroughContainer = objc_getAssociatedObject(viewController.view, &kPassthroughViewKey);
    [self removePassthroughContainerView:passthroughContainer animated:animated];
}

#pragma mark - VPassthroughContainerViewDelegate

- (void)passthroughViewRecievedTouch:(VPassthroughContainerView *)passthroughContainerView
{
    [self removePassthroughContainerView:passthroughContainerView animated:YES];
}

#pragma mark - Adding and removing coachmark views

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

- (void)addCoachmarkView:(VCoachmarkView *)coachmarkView toViewController:(UIViewController *)viewController
{
    UIView *keyView = viewController.view;
    VNavigationController *navigationController = [viewController v_navigationController];
    if ( navigationController != nil )
    {
        viewController = navigationController;
    }
    
    UIView *view = viewController.view;
    VPassthroughContainerView *passthroughOverlay = [[VPassthroughContainerView alloc] initWithFrame:view.bounds];
    passthroughOverlay.delegate = self;
    [passthroughOverlay addSubview:coachmarkView];
    passthroughOverlay.alpha = 0.0f;
    [view addSubview:passthroughOverlay];
    [self animateOverlayView:passthroughOverlay toVisible:YES animated:YES withCompletion:^(BOOL finished)
    {
        [self addHideTimerForCoachmarkView:coachmarkView inPassthroughContainerView:passthroughOverlay];
        [coachmarkView setHasBeenShown:YES];
        objc_setAssociatedObject(keyView, &kPassthroughViewKey, passthroughOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self saveShownStateOfCoachmarks];
    }];
}

- (void)addHideTimerForCoachmarkView:(VCoachmarkView *)coachmarkView inPassthroughContainerView:(VPassthroughContainerView *)passthroughContainerView
{
    NSUInteger displayDuration = coachmarkView.coachmark.displayDuration;
    if ( displayDuration != 0 )
    {
        VTimerManager *hideTimer = [VTimerManager scheduledTimerManagerWithTimeInterval:displayDuration target:self selector:@selector(hideTimerFired:) userInfo:@{ kPassthroughContainerViewKey : passthroughContainerView } repeats:NO];
        [self.hideTimers addObject:hideTimer];
    }
}

- (void)hideTimerFired:(VTimerManager *)timerManager
{
    [self removePassthroughContainerView:[timerManager.userInfo objectForKey:kPassthroughContainerViewKey] animated:YES];
    [self.hideTimers removeObject:timerManager];
}

- (CGRect)frameForTooltipCoachmarkViewWithSize:(CGSize)size arrowDirection:(VCoachmarkArrowDirection)arrowDirection andTargetLocation:(CGRect)targetLocation inViewController:(UIViewController *)viewController
{
    CGRect frame = [self centeredCoachmarkViewFrameWithSize:size inViewController:viewController];
    CGFloat yOrigin = 0;
    switch (arrowDirection)
    {
        case VCoachmarkArrowDirectionUp:
            yOrigin = CGRectGetMaxY(targetLocation);
            break;
            
        case VCoachmarkArrowDirectionDown:
            yOrigin = CGRectGetMinY(targetLocation) - CGRectGetHeight(frame) - kCoachmarkVerticalInset;
            break;
            
        default:
            break;
    }
    frame.origin.y = yOrigin;
    return frame;
}

- (CGRect)frameForToastCoachmarkViewWithSize:(CGSize)size andToastLocation:(VToastLocation)toastLocation inViewController:(UIViewController *)viewController
{
    CGRect frame = [self centeredCoachmarkViewFrameWithSize:size inViewController:viewController];
    CGFloat yOrigin = 0;
    CGFloat topBarHeight = [viewController v_layoutInsets].top;
    switch (toastLocation)
    {
        case VToastLocationTop:
            yOrigin = topBarHeight + kCoachmarkVerticalInset;
            break;
            
        case VToastLocationMiddle:
            yOrigin = ( CGRectGetHeight(viewController.view.bounds) + topBarHeight - size.height ) / 2;
            break;
            
        case VToastLocationBottom:
            yOrigin = CGRectGetHeight(viewController.view.bounds) - size.height - kCoachmarkVerticalInset;
            break;
            
        default:
            break;
    }
    frame.origin.y = yOrigin;
    return frame;
}

- (CGRect)centeredCoachmarkViewFrameWithSize:(CGSize)size inViewController:(UIViewController *)viewController
{
    CGRect frame = CGRectZero;
    frame.size = size;
    frame.origin = CGPointMake(( CGRectGetWidth(viewController.view.frame) - size.width ) / 2, 0);
    return frame;
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
        completion(YES);
    }
}

#pragma mark - Shown coachmark storage

- (void)saveShownStateOfCoachmarks
{
    [[NSUserDefaults standardUserDefaults] setObject:[self shownCoachmarkIds] forKey:kShownCoachmarksKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)shownCoachmarkIds
{
    NSMutableArray *shownCoachmarkIds = [[NSMutableArray alloc] init];
    for (VCoachmark *coachmark in self.coachmarks )
    {
        if ( coachmark.hasBeenShown )
        {
            [shownCoachmarkIds addObject:coachmark.remoteId];
        }
    }
    return [shownCoachmarkIds copy];
}

@end
