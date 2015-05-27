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
#import "VCoachmarkDisplayResponder.h"
#import "VNavigationController.h"
#import "UIViewController+VLayoutInsets.h"
#import "VTimerManager.h"
#import "VCoachmarkPassthroughContainerView.h"
#import "VCoachmarkManager+VObjectAssociation.h"

static NSString * const kShownCoachmarksKey = @"shownCoachmarks";
static NSString * const kReturnedCoachmarksKey = @"coachmarks";
static NSString * const kPassthroughContainerViewKey = @"passthroughContainerView";
static const CGFloat kAnimationDuration = 0.4f;
static const CGFloat kCoachmarkHorizontalInset = 24.0f;
static const CGFloat kCoachmarkVerticalInset = 5.0f;
static const CGFloat kAnimationVerticalOffset = 10.0f;
static const CGFloat kAnimationDelay = 1.0f;

@interface VCoachmarkManager () <VCoachmarkPassthroughContainerViewDelegate>

@property (nonatomic, strong) NSArray *coachmarks;
@property (nonatomic, strong) NSMutableArray *hideTimers;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (atomic, strong) NSMutableArray *removedPassthroughOverlays;

@end

@implementation VCoachmarkManager

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        [self setupWithDependencyManager:dependencyManager];
        _removedPassthroughOverlays = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)resetShownCoachmarks
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kShownCoachmarksKey];
    [self setupWithDependencyManager:self.dependencyManager];
}

- (BOOL)displayCoachmarkViewInViewController:(UIViewController <VCoachmarkDisplayer> *)viewController
{
    NSString *identifier = [viewController screenIdentifier];
    NSMutableArray *validTooltips = [[NSMutableArray alloc] init];
    CGFloat width = CGRectGetWidth(viewController.view.bounds) - kCoachmarkHorizontalInset * 2;
    for ( VCoachmark *coachmark in self.coachmarks )
    {
        if ( !coachmark.hasBeenShown && [coachmark.displayScreens containsObject:identifier] )
        {
            if ( [coachmark.displayTarget isEqualToString:identifier] )
            {
                //Found a toast to display, display it!
                VCoachmarkView *coachmarkView = [VCoachmarkView toastCoachmarkViewWithCoachmark:coachmark
                                                                                       andWidth:width];
                coachmarkView.frame = [self frameForToastCoachmarkViewWithSize:coachmarkView.frame.size andToastLocation:coachmarkView.coachmark.toastLocation inViewController:viewController];
                [self addCoachmarkView:coachmarkView toViewController:viewController];
                return YES;
            }
            else
            {
                //Found a tooltip, add it to our list of valid tooltips so we don't miss an opportunity to show a toast first
                [validTooltips addObject:coachmark];
            }
        }
    }
    
    for ( VCoachmark *tooltip in validTooltips )
    {
        //Didn't have a toast to show, try to show the possible tooltips
        if ( [self addTooltipCoachmark:tooltip withWidth:width toViewController:viewController] )
        {
            return YES;
        }
    }
    return NO;
}

- (void)hideCoachmarkViewInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self removePassthroughContainerView:[self coachmarkPassthroughContainerViewAssociatedWithView:viewController.view] animated:animated];
}

#pragma mark - Setup

- (void)setupWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(dependencyManager != nil);
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

- (BOOL)addTooltipCoachmark:(VCoachmark *)coachmark withWidth:(CGFloat)width toViewController:(UIViewController *)viewController
{
    UIResponder <VCoachmarkDisplayResponder> *nextResponder = [viewController targetForAction:@selector(findOnScreenMenuItemWithIdentifier:andCompletion:) withSender:self];
    if ( nextResponder == nil )
    {
        //There is nobody in the responder chain that responds to
        //findOnScreenMenuItemWithIdentifier:andCompletion:, so there
        //is no way to find out where to point. Look for the next coachmark.
        return NO;
    }
    
    __block BOOL foundDisplayableCoachmark = NO;
    __block CGRect menuItemLocation = CGRectZero;
    [nextResponder findOnScreenMenuItemWithIdentifier:coachmark.displayTarget andCompletion:^(BOOL found, CGRect location)
     {
         foundDisplayableCoachmark = found;
         menuItemLocation = location;
     }];
    
    if ( foundDisplayableCoachmark )
    {
        CGFloat arrowCenter = CGRectGetMidX(menuItemLocation) - kCoachmarkHorizontalInset;
        CGFloat viewHeight = CGRectGetHeight(viewController.view.bounds) - [viewController v_layoutInsets].top;
        VTooltipArrowDirection direction = CGRectGetMidY(menuItemLocation) > viewHeight / 2 ? VTooltipArrowDirectionDown : VTooltipArrowDirectionUp;
        
        //Enforce min and max arrow center values
        arrowCenter = MAX(arrowCenter, VMinimumTooltipArrowLocation);
        arrowCenter = MIN(arrowCenter, width - VMinimumTooltipArrowLocation);
        
        VCoachmarkView *coachmarkView = [VCoachmarkView tooltipCoachmarkViewWithCoachmark:coachmark
                                                                                    width:width
                                                                    arrowHorizontalOffset:arrowCenter
                                                                        andArrowDirection:direction];
        coachmarkView.frame = [self frameForTooltipCoachmarkViewWithSize:coachmarkView.frame.size
                                                          arrowDirection:direction
                                                       andTargetLocation:menuItemLocation
                                                        inViewController:viewController];
        [self addCoachmarkView:coachmarkView toViewController:viewController];
    }
    return foundDisplayableCoachmark;
}

- (void)removePassthroughContainerView:(VCoachmarkPassthroughContainerView *)passthroughContainerView animated:(BOOL)animated
{
    if ( passthroughContainerView != nil )
    {
        if ( !passthroughContainerView.coachmarkView.hasBeenShown )
        {
            //The coachmarkView associated with this passthrough view hasn't shown yet,
            //add it to the removed overlays array to cancel showing it
            [self.removedPassthroughOverlays addObject:passthroughContainerView];
        }
        [self removeAssociationForCoachmarkPassthroughContainerView:passthroughContainerView];
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
    VCoachmarkPassthroughContainerView *passthroughOverlay = [VCoachmarkPassthroughContainerView coachmarkPassthroughContainerViewWithCoachmarkView:coachmarkView andDelegate:self];
    passthroughOverlay.frame = view.bounds;
    [self associateView:keyView withCoachmarkPassthroughContainerView:passthroughOverlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       if ( [self.removedPassthroughOverlays containsObject:passthroughOverlay] )
                       {
                           //Abort! The user navigated offscreen before the overlay view had a chance to display
                           [self.removedPassthroughOverlays removeObject:passthroughOverlay];
                           return;
                       }
                       
                       passthroughOverlay.alpha = 0.0f;
                       [view addSubview:passthroughOverlay];
                       [coachmarkView setHasBeenShown:YES];
                       [self saveShownStateOfCoachmarks];
                       [self animateOverlayView:passthroughOverlay
                                      toVisible:YES
                                       animated:YES
                                 withCompletion:^(BOOL finished)
                        {
                            [self addHideTimerForCoachmarkView:coachmarkView inPassthroughContainerView:passthroughOverlay];
                        }];
                   });
}

- (void)addHideTimerForCoachmarkView:(VCoachmarkView *)coachmarkView inPassthroughContainerView:(VCoachmarkPassthroughContainerView *)passthroughContainerView
{
    NSUInteger displayDuration = coachmarkView.coachmark.displayDuration;
    if ( displayDuration != 0 )
    {
        VTimerManager *hideTimer = [VTimerManager scheduledTimerManagerWithTimeInterval:displayDuration target:self selector:@selector(hideTimerFired:) userInfo:passthroughContainerView repeats:NO];
        [self.hideTimers addObject:hideTimer];
    }
}

- (void)hideTimerFired:(VTimerManager *)timerManager
{
    if ( [timerManager.userInfo isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
    {
        [self removePassthroughContainerView:(VCoachmarkPassthroughContainerView *)timerManager.userInfo animated:YES];
    }
    [self.hideTimers removeObject:timerManager];
}

- (CGRect)frameForTooltipCoachmarkViewWithSize:(CGSize)size arrowDirection:(VTooltipArrowDirection)arrowDirection andTargetLocation:(CGRect)targetLocation inViewController:(UIViewController *)viewController
{
    CGRect frame = [self centeredCoachmarkViewFrameWithSize:size inViewController:viewController];
    
    //Check to see that we can properly point to the intended location
    CGFloat horizontalLocation = CGRectGetMidX(targetLocation);
    CGFloat minimumLocation = CGRectGetMinX(frame) + VMinimumTooltipArrowLocation;
    CGFloat maximumLocation = CGRectGetMaxX(frame) - VMinimumTooltipArrowLocation;
    CGFloat xOffset = 0;
    if ( horizontalLocation < minimumLocation )
    {
        xOffset = horizontalLocation - minimumLocation;
    }
    else if ( horizontalLocation > maximumLocation)
    {
        xOffset = horizontalLocation - maximumLocation;
    }
    frame.origin.x += xOffset;
    CGFloat yOrigin = 0;
    switch (arrowDirection)
    {
        case VTooltipArrowDirectionUp:
            yOrigin = CGRectGetMaxY(targetLocation) + kCoachmarkVerticalInset;
            break;
            
        case VTooltipArrowDirectionDown:
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
    
    if ( animated )
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.0f
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
    BOOL isTooltip = coachmarkView.arrowDirection != VTooltipArrowDirectionInvalid;
    BOOL shouldSlideUp = (!isTooltip && coachmarkView.coachmark.toastLocation == VToastVerticalLocationTop) || coachmarkView.arrowDirection == VTooltipArrowDirectionUp;
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
