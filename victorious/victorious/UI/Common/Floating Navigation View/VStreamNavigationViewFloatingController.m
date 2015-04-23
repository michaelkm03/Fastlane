//
//  VStreamNavigationViewFloatingController.m
//  victorious
//
//  Created by Patrick Lynch on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamNavigationViewFloatingController.h"
#import "UIView+AutoLayout.h"

/**
 @see http://gizma.com/easing/
 */
static CGFloat easeInSine( CGFloat t )
{
    CGFloat b = 0.0f;
    CGFloat c = 1.0f;
    CGFloat d = 1.0f;
    return -c * cos(t/d * (M_PI_2)) + c + b;
};

@interface VStreamNavigationViewFloatingController()

@property (nonatomic, assign) BOOL hasBeenSetup;
@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGPoint scrollVelocity;
@property (nonatomic, assign) CGFloat alternatingRotationMultiplier;
@property (nonatomic, assign, readonly) CGFloat velocityMultiplier;

@property (nonatomic, weak) UIView *floatingView;
@property (nonatomic, weak) UIViewController *floatingParentViewController;

@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, assign) CGFloat targetVisibility;
@property (nonatomic, assign) CGFloat visibility;

@property (nonatomic, assign) CGFloat verticalScrollThresholdStart;
@property (nonatomic, assign) CGFloat verticalScrollThresholdEnd;

@end

@implementation VStreamNavigationViewFloatingController

@synthesize delegate;
@synthesize animationEnabled = _animationEnabled;

- (instancetype)initWithFloatingView:(UIView *)floatingView
        floatingParentViewController:(UIViewController *)floatingParentViewController
        verticalScrollThresholdStart:(CGFloat)verticalScrollThresholdStart
          verticalScrollThresholdEnd:(CGFloat)verticalScrollThresholdEnd
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( floatingView != nil );
        NSParameterAssert( floatingParentViewController != nil );
        NSParameterAssert( verticalScrollThresholdStart < verticalScrollThresholdEnd );
        
        _verticalScrollThresholdStart = verticalScrollThresholdStart;
        _verticalScrollThresholdEnd = verticalScrollThresholdEnd;
        
        _floatingParentViewController = floatingParentViewController;
        _floatingView = floatingView;
        _alternatingRotationMultiplier = 1.0f;
        
        [self setupViews];
    }
    return self;
}

- (void)setVerticalThresholdWithStart:(CGFloat)start end:(CGFloat)end
{
    NSParameterAssert( start < end );
    
    self.verticalScrollThresholdStart = start;
    self.verticalScrollThresholdEnd = end;
}

- (void)setAnimationEnabled:(BOOL)animationEnabled
{
    _animationEnabled = animationEnabled;
    
    if ( _animationEnabled )
    {
        self.animationTimer = [NSTimer timerWithTimeInterval:1.0f/60.0f //< 60 FPS
                                                      target:self
                                                    selector:@selector(updateAnimation)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
        self.floatingView.hidden = NO;
    }
    else
    {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
    
    const CGFloat targetAlpha = animationEnabled ? 1.0f : 0.0f;
    const CGFloat delay = animationEnabled ? 0.5f : 0.0f;
    [UIView animateWithDuration:0.2f
                          delay:delay
                        options:kNilOptions animations:^
    {
        self.floatingView.alpha = targetAlpha;
    }
     completion:nil];
}

- (void)setupViews
{
    if ( self.floatingParentViewController == nil || self.floatingView == nil )
    {
        return;
    }
    
    UIView *floatingParent = self.floatingParentViewController.view;
    [floatingParent addSubview:self.floatingView];
    self.floatingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.floatingView removeConstraints:self.floatingView.constraints];
    
    self.floatingView.userInteractionEnabled = YES;
    UIButton *button = [[UIButton alloc] initWithFrame:self.floatingView.bounds];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(floatingViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatingView addSubview:button];
    [self.floatingView v_addFitToParentConstraintsToSubview:button];
    
    NSLayoutConstraint *center = [NSLayoutConstraint constraintWithItem:self.floatingView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:floatingParent
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0f
                                                               constant:0.0f];
    [floatingParent addConstraint:center];
    NSDictionary *views = @{ @"view" : self.floatingView };
    NSDictionary *metrics = @{ @"width" : @(CGRectGetWidth(self.floatingView.frame)),
                               @"height" : @(CGRectGetHeight(self.floatingView.frame)),
                               @"top" : @20 };
    [floatingParent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(width)]"
                                                                           options:kNilOptions
                                                                           metrics:metrics
                                                                             views:views]];
    [floatingParent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[view(height)]"
                                                                           options:kNilOptions
                                                                           metrics:metrics
                                                                             views:views]];
    self.hasBeenSetup = YES;
    
    self.targetVisibility = self.visibility = 0.0f;
    [self updateAnimation];
}

- (void)floatingViewButtonTapped:(UIButton *)button
{
    [self.delegate floatingViewSelected:self.floatingView];
}

- (void)updateContentOffsetOnScroll:(CGPoint)contentOffset
{
    const CGFloat start = self.verticalScrollThresholdStart;
    const CGFloat end = self.verticalScrollThresholdEnd;
    self.targetVisibility = MIN( MAX( (contentOffset.y - start) / (end - start), 0.0f ), 1.0f );
    
    // Calculate scroll speed in screen points to be used for calculations in aniamtion later on
    self.scrollVelocity = CGPointMake( contentOffset.x - self.lastContentOffset.x,
                                       contentOffset.y - self.lastContentOffset.y );
    self.lastContentOffset = contentOffset;
}

- (void)updateAnimation
{
    self.visibility += (self.targetVisibility - self.visibility) / 5.0f;
    
    CATransform3D transform = CATransform3DIdentity;
    const CGFloat eyePosition = 50.0;
    transform.m34 = -1.0 / eyePosition;
    const CGFloat translationZ = 40.0f;
    transform = CATransform3DTranslate( transform, 0.0f, 0.0f, -translationZ );
    transform = CATransform3DRotate( transform, easeInSine(1.0f - self.visibility) * -M_PI_2, 1.0f, 0.0f, 0.0f );
    transform = CATransform3DTranslate( transform, 0.0f, 0.0f, translationZ );
    self.floatingView.layer.zPosition = 1000;
    self.floatingView.layer.transform = transform;
    self.floatingView.alpha = easeInSine( self.visibility * 1.0f );
}

/**
 Using the velocity calcuated in `updateContentOffsetOnScroll:` method, we calculate
 a multplier to speed up animations (shorten duration) according to how fast the user
 is scrolling.
 */
- (CGFloat)velocityMultiplier
{
    const CGFloat value = ABS( self.scrollVelocity.y ) / 120.0f;
    return 1.0f - MIN( 0.9f, MAX( value, 0.0f ) );
}

@end
