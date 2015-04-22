//
//  VStreamNavigationViewFloatingController.m
//  victorious
//
//  Created by Patrick Lynch on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamNavigationViewFloatingController.h"
#import "UIView+AutoLayout.h"

static const CGFloat kAnimationDurationShow = 1.0f;
static const CGFloat kAnimationDurationHide = 0.4f;
static const CGFloat kVerticalTranslation = 5.0f;
static const CGFloat kScaleHide = 0.4f;

@interface VStreamNavigationViewFloatingController()

@property (nonatomic, assign) BOOL hasBeenSetup;
@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGPoint scrollVelocity;
@property (nonatomic, assign) CGFloat alternatingRotationMultiplier;
@property (nonatomic, assign, readonly) CGFloat velocityMultiplier;

@property (nonatomic, weak) UIView *floatingView;
@property (nonatomic, weak) UIViewController *floatingParentViewController;

@end

@implementation VStreamNavigationViewFloatingController

@synthesize verticalScrollThreshold = _verticalScrollThreshold;
@synthesize delegate;

- (instancetype)initWithFloatingView:(UIView *)floatingView
        floatingParentViewController:(UIViewController *)floatingParentViewController
             verticalScrollThreshold:(CGFloat)verticalScrollThreshold
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( floatingView != nil );
        NSParameterAssert( floatingParentViewController != nil );
        
        _verticalScrollThreshold = verticalScrollThreshold;
        _floatingParentViewController = floatingParentViewController;
        _floatingView = floatingView;
        _alternatingRotationMultiplier = 1.0f;
        
        [self setupViews];
    }
    return self;
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
    
    [self setVisible:NO];
}

- (void)floatingViewButtonTapped:(UIButton *)button
{
    [self.delegate floatingViewSelected:self.floatingView];
}

- (void)updateContentOffsetOnScroll:(CGPoint)contentOffset
{
    if ( contentOffset.y >= self.verticalScrollThreshold )
    {
        [self show];
    }
    else
    {
        [self hide];
    }
    
    // Calculate scroll speed in screen points to be used for calculations in aniamtion later on
    self.scrollVelocity = CGPointMake( contentOffset.x - self.lastContentOffset.x,
                                       contentOffset.y - self.lastContentOffset.y );
    self.lastContentOffset = contentOffset;
}

- (void)setVisible:(BOOL)visible
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    if ( visible )
    {
        transform = CGAffineTransformRotate( transform, 0.0f );
        transform = CGAffineTransformScale( transform, 1.0f, 1.0f );
        transform = CGAffineTransformTranslate( transform, 0.0f, 0.0f );
    }
    else
    {
        // Alternate rotation direction so that rotation in/out are oppsite next time:
        self.alternatingRotationMultiplier *= -1.0f;
        
        transform = CGAffineTransformTranslate( transform, 0.0f, kVerticalTranslation );
        transform = CGAffineTransformScale( transform, kScaleHide, kScaleHide );
        const CGFloat rotationZ = self.alternatingRotationMultiplier * (M_PI - 0.01);
        transform = CGAffineTransformRotate( transform, rotationZ );
    }
    self.floatingView.transform = transform;
    self.floatingView.alpha = visible ? 1.0f : 0.0f;
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

- (void)hide
{
    if ( !self.isVisible )
    {
        return;
    }
    self.isVisible = NO;
    
    [UIView animateWithDuration:self.velocityMultiplier * kAnimationDurationHide
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         [self setVisible:NO];
     }
                     completion:nil];
}

- (void)show
{
    if ( self.isVisible )
    {
        return;
    }
    
    self.isVisible = YES;
    
    [UIView animateWithDuration:self.velocityMultiplier * kAnimationDurationShow
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.5f
                        options:kNilOptions
                     animations:^
     {
         [self setVisible:YES];
     }
                     completion:nil];
}

@end
