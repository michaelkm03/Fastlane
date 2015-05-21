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
#import "VCoachmarkPassthroughContainerView.h"

#define CLEAR_SHOWN_COACHMARKS 1

static NSString * const kShownCoachmarksKey = @"shownCoachmarks";
static NSString * const kReturnedCoachmarksKey = @"coachmarks";
static NSString * const kPassthroughContainerViewKey = @"passthroughContainerView";
static const CGFloat kAnimationDuration = 0.4f;
static const char kPassthroughViewKey;
static const CGFloat kCoachmarkHorizontalInset = 24.0f;
static const CGFloat kCoachmarkVerticalInset = 5.0f;
static const CGFloat kAnimationVerticalOffset = 10.0f;
static const CGFloat kAnimationDelay = 1.0f;

@interface VCoachmarkManager () <VCoachmarkPassthroughContainerViewDelegate>

@property (nonatomic, strong) NSArray *coachmarks;
@property (nonatomic, strong) NSMutableArray *hideTimers;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCoachmarkManager

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        [self setupWithDependencyManager:dependencyManager];
    }
    return self;
}

- (void)resetShownCoachmarks
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kShownCoachmarksKey];
    [self setupWithDependencyManager:self.dependencyManager];
}

- (void)displayCoachmarkViewInViewController:(UIViewController <VCoachmarkDisplayer> *)viewController
{
    NSString *identifier = [viewController screenIdentifier];
    for ( VCoachmark *coachmark in self.coachmarks )
    {
        if ( !coachmark.hasBeenShown && [coachmark.displayScreens containsObject:identifier] )
        {
            CGFloat maxWidth = CGRectGetWidth(viewController.view.bounds) - kCoachmarkHorizontalInset * 2;
            if ( [coachmark.displayTarget isEqualToString:identifier] )
            {
                //Displaying as a toast
                VCoachmarkView *coachmarkView = [VCoachmarkView toastCoachmarkViewWithCoachmark:coachmark andMaxWidth:maxWidth];
                coachmarkView.frame = [self frameForToastCoachmarkViewWithSize:coachmarkView.frame.size andToastLocation:coachmarkView.coachmark.toastLocation inViewController:viewController];
                [self addCoachmarkView:coachmarkView toViewController:viewController];
                break;
            }
            else
            {
                UIResponder <VCoachmarkDisplayResponder> *nextResponder = [viewController targetForAction:@selector(findOnScreenMenuItemWithIdentifier:andCompletion:) withSender:self];
                if ( nextResponder == nil )
                {
                    NSAssert(false, @"Need a responder for findOnScreenMenuItemWithIdentifier:andCompletion:");
                    return;
                }
                
                __block BOOL foundDisplayableCoachmark = NO;
                [nextResponder findOnScreenMenuItemWithIdentifier:coachmark.displayTarget andCompletion:^(BOOL found, CGRect location)
                 {
                     foundDisplayableCoachmark = found;
                     if ( found )
                     {
                         CGFloat arrowCenter = CGRectGetMidX(location) - kCoachmarkHorizontalInset;
                         CGFloat viewHeight = CGRectGetHeight(viewController.view.bounds) - [viewController v_layoutInsets].top;
                         VCoachmarkArrowDirection direction = CGRectGetMidY(location) > viewHeight / 2 ? VCoachmarkArrowDirectionDown : VCoachmarkArrowDirectionUp;
                         VCoachmarkView *coachmarkView = [VCoachmarkView tooltipCoachmarkViewWithCoachmark:coachmark
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
                
                if ( foundDisplayableCoachmark )
                {
                    break;
                }
            }
        }
    }
}

- (void)hideCoachmarkViewInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self removePassthroughContainerView:objc_getAssociatedObject(viewController.view, &kPassthroughViewKey) animated:animated];
}

#pragma mark - setup

- (void)setupWithDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    NSArray *shownCoachmarkIds = [self savedShownStatesOfCoachmarks];
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

#pragma mark - VPassthroughContainerViewDelegate

- (void)passthroughViewRecievedTouch:(VCoachmarkPassthroughContainerView *)passthroughContainerView
{
    [self removePassthroughContainerView:passthroughContainerView animated:YES];
}

#pragma mark - Adding and removing coachmark views

- (void)removePassthroughContainerView:(VCoachmarkPassthroughContainerView *)passthroughContainerView animated:(BOOL)animated
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
    VCoachmarkPassthroughContainerView *passthroughOverlay = [VCoachmarkPassthroughContainerView coachmarkPassthroughContainerViewWithCoachmarkView:coachmarkView frame:view.bounds andDelegate:self];
    [passthroughOverlay addSubview:coachmarkView];
    passthroughOverlay.alpha = 0.0f;
    [view addSubview:passthroughOverlay];
    [self animateOverlayView:passthroughOverlay
                   toVisible:YES
                    animated:YES
              withCompletion:^(BOOL finished)
    {
        [self addHideTimerForCoachmarkView:coachmarkView inPassthroughContainerView:passthroughOverlay];
        [coachmarkView setHasBeenShown:YES];
        objc_setAssociatedObject(keyView, &kPassthroughViewKey, passthroughOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self saveShownStateOfCoachmarks];
    }];
}

- (void)addHideTimerForCoachmarkView:(VCoachmarkView *)coachmarkView inPassthroughContainerView:(VCoachmarkPassthroughContainerView *)passthroughContainerView
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
            yOrigin = CGRectGetMaxY(targetLocation) + kCoachmarkVerticalInset;
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

- (CGRect)frameForToastCoachmarkViewWithSize:(CGSize)size andToastLocation:(VToastVerticalLocation)toastLocation inViewController:(UIViewController *)viewController
{
    CGRect frame = [self centeredCoachmarkViewFrameWithSize:size inViewController:viewController];
    CGFloat yOrigin = 0;
    CGFloat topBarHeight = [viewController v_layoutInsets].top;
    switch (toastLocation)
    {
        case VToastVerticalLocationTop:
            yOrigin = topBarHeight + kCoachmarkVerticalInset;
            break;
            
        case VToastVerticalLocationMiddle:
            yOrigin = ( CGRectGetHeight(viewController.view.bounds) + topBarHeight - size.height ) / 2;
            break;
            
        case VToastVerticalLocationBottom:
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

- (void)animateOverlayView:(VCoachmarkPassthroughContainerView *)passthroughContainerView
                 toVisible:(BOOL)visible
                  animated:(BOOL)animated
            withCompletion:(void (^)(BOOL))completion
{
    VCoachmarkView *coachmarkView = passthroughContainerView.coachmarkView;
    CGRect targetFrame = coachmarkView.frame;
    if ( visible )
    {
        //Set the coachmarkView to an appropriate start frame so that it appears to move to its destination
        coachmarkView.frame = [self frameForAnimatingCoachmarkView:coachmarkView];
    }
    else
    {
        //Set the targetFrame to an approrpriate end frame so that it appears to move from its destination
        targetFrame = [self frameForAnimatingCoachmarkView:coachmarkView];
    }
    
    CGFloat targetAlpha = visible ? 1.0f : 0.0f;
    CGFloat animationDelay = visible ? kAnimationDelay : 0.0f;
    
    if ( animated )
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             passthroughContainerView.alpha = targetAlpha;
             coachmarkView.frame = targetFrame;
         }
                         completion:completion];
    }
    else
    {
        passthroughContainerView.alpha = targetAlpha;
        coachmarkView.frame = targetFrame;
        completion(YES);
    }
}

- (CGRect)frameForAnimatingCoachmarkView:(VCoachmarkView *)coachmarkView
{
    BOOL isTooltip = coachmarkView.arrowDirection != VCoachmarkArrowDirectionInvalid;
    BOOL shouldSlideUp = (!isTooltip && coachmarkView.coachmark.toastLocation == VToastVerticalLocationTop) || coachmarkView.arrowDirection == VCoachmarkArrowDirectionUp;
    CGRect frame = coachmarkView.frame;
    frame.origin.y += shouldSlideUp ? kAnimationVerticalOffset : -kAnimationVerticalOffset;
    return frame;
}

#pragma mark - Shown coachmark storage

- (void)saveShownStateOfCoachmarks
{
    [[NSUserDefaults standardUserDefaults] setObject:[self shownCoachmarkIds] forKey:kShownCoachmarksKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)shownCoachmarkIds
{
    NSMutableArray *shownCoachmarkIds = [[NSMutableArray alloc] initWithArray:[self savedShownStatesOfCoachmarks]];
    for (VCoachmark *coachmark in self.coachmarks )
    {
        if ( coachmark.hasBeenShown )
        {
            [shownCoachmarkIds addObject:coachmark.remoteId];
        }
    }
    return [shownCoachmarkIds copy];
}

- (NSArray *)savedShownStatesOfCoachmarks
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kShownCoachmarksKey];
}

@end
