//
//  VFollowControl.m
//  victorious
//
//  Created by Sharif Ahmed on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowControl.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager.h"

static const CGFloat kHighlightedTiltRotationAngle = M_PI / 4;
static const NSTimeInterval kHighlightAnimationDuration = 0.3f;
static const CGFloat kHighlightTransformPerspective = -1.0 / 200.0f;
static const CGFloat kForcedAntiAliasingConstant = 0.01f;
static const CGFloat kActivityIndicatorShowDuration = 0.5f;
static const CGFloat kActivityIndicatorHideDuration = 0.0f;

static NSString * const kFollowIconKey = @"follow_user_icon";
static NSString * const kFollowedCheckmarkIconKey = @"followed_user_icon";
static NSString * const kFollowedBackgroundIconKey = @"followed_user_background_icon";

@interface VFollowControl ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIColor *activityIndicatorTintColor;

@property (nonatomic, strong) UIImage *onImage;
@property (nonatomic, strong) UIImage *offImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

@end

@implementation VFollowControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImageView.backgroundColor = [UIColor clearColor];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:backgroundImageView];
    [self v_addFitToParentConstraintsToSubview:backgroundImageView];
    _backgroundImageView = backgroundImageView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:imageView];
    [self v_addFitToParentConstraintsToSubview:imageView];
    _imageView = imageView;
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self performHighlightAnimations:^
     {
         self.layer.transform = highlighted ? [self highlightTransform] : CATransform3DIdentity;
         self.layer.shadowOpacity = kForcedAntiAliasingConstant;
     }];
}

#pragma mark - Activity indicator management

- (void)createActivityIndicator
{
    if ( self.activityIndicator == nil )
    {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        if ( self.activityIndicatorTintColor != nil )
        {
            self.activityIndicator.color = self.activityIndicatorTintColor;
        }
        [self addSubview:_activityIndicator];
        [self v_addCenterToParentContraintsToSubview:_activityIndicator];
        self.activityIndicator.alpha = 0.0f;
    }
    [self.activityIndicator startAnimating];
}

- (void)setActivityIndicatorTintColor:(UIColor *)activityIndicatorTintColor
{
    _activityIndicatorTintColor = activityIndicatorTintColor;
    self.activityIndicator.color = activityIndicatorTintColor;
}

- (void)setShowActivityIndicator:(BOOL)showActivityIndicator
{
    _showActivityIndicator = showActivityIndicator;
    if ( showActivityIndicator )
    {
        [self createActivityIndicator];
        
        self.imageView.alpha = 0.0f;
        self.backgroundImageView.alpha = 0.0f;
        [UIView animateWithDuration:kActivityIndicatorShowDuration animations:^
         {
             self.activityIndicator.alpha = 1.0f;
         }
                         completion:nil];
    }
    else
    {
        self.activityIndicator.alpha = 0.0f;
        if ( !self.activityIndicator.isAnimating )
        {
            //Activity indicator isn't showing, don't animate the imageview re-appearance
            self.imageView.alpha = 1.0f;
            self.backgroundImageView.alpha = 1.0f;
        }
        else
        {
            //Animate the imageView alpha change
            [UIView animateWithDuration:kActivityIndicatorHideDuration animations:^
             {
                 self.imageView.alpha = 1.0f;
                 self.backgroundImageView.alpha = 1.0f;
             }
                             completion:nil];
        }
    }
}

#pragma mark - Animations

- (void)performHighlightAnimations:(void (^)(void))animations
{
    [UIView animateWithDuration:kHighlightAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:nil];
}

- (CATransform3D)highlightTransform
{
    CATransform3D highLightTranform = CATransform3DIdentity;
    
    highLightTranform.m34 = kHighlightTransformPerspective;
    highLightTranform = CATransform3DRotate(highLightTranform, kHighlightedTiltRotationAngle, 1, 0, 0);
    
    return highLightTranform;
}

- (void)setFollowing:(BOOL)following animated:(BOOL)animated
{
    void (^animationBlock)(void) = ^
    {
        self.following = following;
    };
    
    if ( !animated )
    {
        animationBlock();
        return;
    }
    
    [UIView transitionWithView:self
                      duration:kHighlightAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionBeginFromCurrentState
                    animations:animationBlock
                    completion:nil];
}

#pragma mark - Appearance styling

- (void)updateFollowImageView
{
    UIImage *backgroundImage = nil;
    UIImage *foregroundImage = self.offImage;
    if ( self.following )
    {
        backgroundImage = self.selectedBackgroundImage;
        foregroundImage = self.onImage;
    }
    self.backgroundImageView.image = backgroundImage;
    self.imageView.image = foregroundImage;
}

#pragma mark - Setters

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.backgroundImageView.tintColor = tintColor;
}

- (void)setFollowing:(BOOL)following
{
    _following = following;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [self updateFollowImageView];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.onImage = [[dependencyManager imageForKey:kFollowedCheckmarkIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.offImage = [[dependencyManager imageForKey:kFollowIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.selectedBackgroundImage = [[dependencyManager imageForKey:kFollowedBackgroundIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIColor *tintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.tintColor = tintColor;
        self.activityIndicatorTintColor = tintColor;
        [self updateFollowImageView];
    }
}

#pragma mark - Interface Builder

- (void)prepareForInterfaceBuilder
{
    [self sharedInit];
}

@end
