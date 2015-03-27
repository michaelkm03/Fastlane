//
//  VFollowUserControl.m
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowUserControl.h"
#import "VThemeManager.h"

static const CGFloat kHighlightedTiltRotationAngle = M_PI / 4;
static const NSTimeInterval kHighlightAnimationDuration = 0.3f;
static const CGFloat kHighlightTransformPerspective = -1.0 / 200.0f;
static const CGFloat kForcedAntiAliasingConstant = 0.01f;

@interface VFollowUserControl ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic) UIImage *followImage;
@property (nonatomic) UIImage *followedImage;
@property (nonatomic) UIImage *unFollowImage;

@end

@implementation VFollowUserControl

#pragma mark - Initializer

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
#if TARGET_INTERFACE_BUILDER
    _followImage = [UIImage imageNamed:@"folllowIcon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    _followedImage = [UIImage imageNamed:@"folllowedIcon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
#else
    _followImage = [UIImage imageNamed:@"folllowIcon"];
    _followedImage = [UIImage imageNamed:@"folllowedIcon"];
#endif

    UIImageView *imageView = [[UIImageView alloc] initWithImage:_followImage];
    imageView.frame = self.bounds;
    imageView.contentMode = self.contentMode;
    
    if (self.following)
    {
        [imageView setImage:_followedImage];
    }
    else
    {
        UIImage *sImg = [_followImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        imageView.image = sImg;
    }
    [self addSubview:imageView];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:0.0f];
    NSLayoutConstraint *rightContstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    [self addConstraints:@[topConstraint, rightContstraint, bottomConstraint, leftConstraint]];
    
    _imageView = imageView;
}

#pragma mark - Property Accessors

- (void)setFollowing:(BOOL)following
{
    if (_following == following)
    {
        return;
    }
    
    _following = following;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (self.following)
    {
        [self.imageView setImage:_followedImage];
    }
    else
    {
        UIImage *sImg = [_followImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.imageView.image = sImg;
    }

}

#pragma mark - Public Interface

- (void)setFollowing:(BOOL)following
            animated:(BOOL)animated
{
    void (^animations)() = ^(void)
    {
        self.following = following;
    };
    
    if (!animated)
    {
        animations();
        return;
    }
    
    [UIView transitionWithView:self.imageView
                      duration:kHighlightAnimationDuration
                       options:UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionBeginFromCurrentState
                    animations:animations
                    completion:nil];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.imageView.tintColor = tintColor;
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
                                           
#pragma mark - Interface Builder

- (void)prepareForInterfaceBuilder
{
    [self sharedInit];
}

@end
