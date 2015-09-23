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
static const CGFloat kLoadingColorAlpha = 0.6f;

static NSString * const kFollowIconKey = @"follow_user_icon";
static NSString * const kFollowedCheckmarkIconKey = @"followed_user_icon";
static NSString * const kFollowedBackgroundIconKey = @"followed_user_background_icon";

@interface VFollowControl ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImage *onImage;
@property (nonatomic, strong) UIImage *offImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

@property (nonatomic, strong) UIColor *selectedTintColor;

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

- (void)setControlState:(VFollowControlState)controlState animated:(BOOL)animated
{
    if ( controlState == _controlState )
    {
        return;
    }
    
    //Flip at all times EXCEPT when transitioning FROM following TO loading and TO following FROM loading.
    BOOL shouldFlip = !( ( controlState == VFollowControlStateLoading && self.controlState == VFollowControlStateFollowed ) || ( controlState == VFollowControlStateFollowed && self.controlState == VFollowControlStateLoading ) );
    void (^animationBlock)(void) = ^
    {
        self.controlState = controlState;
    };
    
    if ( !animated )
    {
        animationBlock();
        return;
    }
    
    if ( shouldFlip )
    {
        [UIView transitionWithView:self
                          duration:kHighlightAnimationDuration
                           options:UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionBeginFromCurrentState
                        animations:animationBlock
                        completion:nil];
    }
    else
    {
        [self performHighlightAnimations:animationBlock];
    }
}

#pragma mark - Appearance styling

- (void)updateFollowImageView
{
    UIImage *backgroundImage = nil;
    UIImage *foregroundImage = self.offImage;
    UIColor *tintColor = self.selectedTintColor;
    switch ( self.controlState )
    {
        case VFollowControlStateLoading:
            tintColor = [tintColor colorWithAlphaComponent:kLoadingColorAlpha];
        case VFollowControlStateFollowed: //Deliberate fallthrough!
            foregroundImage = self.onImage;
            backgroundImage = self.selectedBackgroundImage;
            break;
            
        case VFollowControlStateUnfollowed:
        {
            BOOL showUnselectedTintColor = self.unselectedTintColor != nil && self.tintUnselectedImage;
            tintColor = showUnselectedTintColor ? self.unselectedTintColor : self.selectedTintColor;
        }
        default:
            break;
    }
    self.backgroundImageView.image = backgroundImage;
    self.imageView.image = foregroundImage;
    self.tintColor = tintColor;
}

#pragma mark - Setters

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.backgroundImageView.tintColor = tintColor;
}

- (void)setControlState:(VFollowControlState)controlState
{
    _controlState = controlState;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [self updateFollowImageView];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.onImage = [[dependencyManager imageForKey:kFollowedCheckmarkIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.selectedBackgroundImage = [[dependencyManager imageForKey:kFollowedBackgroundIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.selectedTintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        [self updateOffImage];
        [self updateFollowImageView];
    }
}

- (void)setTintUnselectedImage:(BOOL)tintUnselectedImage
{
    _tintUnselectedImage = tintUnselectedImage;
    [self updateOffImage];
    [self updateFollowImageView];
}

- (void)setUnselectedTintColor:(UIColor *)unselectedTintColor
{
    _unselectedTintColor = unselectedTintColor;
    [self updateFollowImageView];
}

- (void)updateOffImage
{
    UIImageRenderingMode renderingMode = self.tintUnselectedImage ? UIImageRenderingModeAlwaysTemplate : UIImageRenderingModeAlwaysOriginal;
    self.offImage = [[self.dependencyManager imageForKey:kFollowIconKey] imageWithRenderingMode:renderingMode];
}

+ (VFollowControlState)controlStateForFollowing:(BOOL)following
{
    return following ? VFollowControlStateFollowed : VFollowControlStateUnfollowed;
}

#pragma mark - Interface Builder

- (void)prepareForInterfaceBuilder
{
    [self sharedInit];
}

@end
