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

static NSString * const kCoachmarksKey = @"coachmarks";
static const CGFloat kAnimationDuration = 0.2f;
static const char kPassthroughViewKey;
static const CGFloat kCoachmarkHorizontalInset = 24;
static const CGFloat kCoachmarkVerticalInset = 5;

@interface VCoachmarkManager () <VPassthroughContainerViewDelegate>

@property (nonatomic, strong) NSArray *coachmarks;

@end

@implementation VCoachmarkManager

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCoachmarksKey];
        if ( data != nil )
        {
            _coachmarks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else
        {
            _coachmarks = @[];
        }
        
        NSArray *returnedCoachmarks = [dependencyManager arrayOfValuesOfType:[VCoachmark class] forKey:kCoachmarksKey];
        NSMutableArray *validCoachmarks = [[NSMutableArray alloc] init];
        for ( VCoachmark *coachmark in returnedCoachmarks )
        {
            NSInteger indexOfCoachmark = [_coachmarks indexOfObject:coachmark];
            if ( indexOfCoachmark != NSNotFound )
            {
#warning FOR TESTING ONLY
                //We already had this coachmark in our array, import its shown state onto the new coachmark
                VCoachmark *oldCoachmark = [_coachmarks objectAtIndex:indexOfCoachmark];
                coachmark.hasBeenShown = NO;//oldCoachmark.hasBeenShown;
            }
            [validCoachmarks addObject:coachmark];
        }
        
        _coachmarks = [validCoachmarks copy];
        [self saveStateOfCoachmarks];
    }
    return self;
}

- (void)displayCoachmarkViewInViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier
{
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

- (void)saveStateOfCoachmarks
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.coachmarks] forKey:kCoachmarksKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        [coachmarkView setHasBeenShown:YES];
        objc_setAssociatedObject(view, &kPassthroughViewKey, passthroughOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self saveStateOfCoachmarks];
    }];
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
            yOrigin = CGRectGetMinY(targetLocation) - kCoachmarkVerticalInset;
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
    }
}

@end
