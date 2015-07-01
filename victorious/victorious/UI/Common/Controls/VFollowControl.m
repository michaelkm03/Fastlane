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

static NSString * const kFollowHashtagIconKey = @"follow_hashtag_icon";
static NSString * const kFollowedHashtagIconKey = @"followed_hashtag_icon";

@interface VFollowControl ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign) UIImage *onImage;
@property (nonatomic, assign) UIImage *offImage;

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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = self.contentMode;
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
         self.imageView.layer.transform = highlighted ? [self highlightTransform] : CATransform3DIdentity;
         self.imageView.layer.shadowOpacity = kForcedAntiAliasingConstant;
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

- (void)setFollowing:(BOOL)following animated:(BOOL)animated withAnimationBlock:(void (^)(void))animationBlock
{
    void (^fullAnimationBlock)(void) = ^
    {
        self.following = following;
        if ( animationBlock != nil )
        {
            animationBlock();
        }
    };
    
    if ( !animated )
    {
        fullAnimationBlock();
        return;
    }
    
    [UIView transitionWithView:self.imageView
                      duration:kHighlightAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionBeginFromCurrentState
                    animations:fullAnimationBlock
                    completion:nil];
}

#pragma mark - Appearance styling

- (void)updateFollowImageView
{
    self.imageView.image = self.isFollowing ? self.onImage : self.offImage;
}

#pragma mark - Setters

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.imageView.tintColor = tintColor;
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
        self.onImage = [dependencyManager imageForKey:kFollowedHashtagIconKey];
        self.offImage = [[dependencyManager imageForKey:kFollowHashtagIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        [self updateFollowImageView];
    }
}

#pragma mark - Interface Builder

- (void)prepareForInterfaceBuilder
{
    [self sharedInit];
}

@end
