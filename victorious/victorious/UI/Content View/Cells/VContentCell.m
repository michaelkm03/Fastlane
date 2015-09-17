//
//  VContentCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCell.h"
#import "UIView+Autolayout.h"
#import <QuartzCore/QuartzCore.h>

@interface VContentCell () <VEndCardViewControllerDelegate>

@property (nonatomic, weak) UIImageView *animationImageView;
@property (nonatomic, strong) VEndCardViewController *endCardViewController;

@end

@implementation VContentCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    animationImageView.backgroundColor = [UIColor clearColor];
    animationImageView.userInteractionEnabled = NO;
    self.animationImageView = animationImageView;
    [self.contentView addSubview:animationImageView];
    
    // Set some initial/default values
    self.maxSize = self.frame.size;
    self.minSize = CGSizeMake( self.frame.size.width, 0.0f );
    
    self.repeatCount = 1;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.shrinkingContentView = [[UIView alloc] initWithFrame:self.bounds];
    self.shrinkingContentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.shrinkingContentView];
    [self.shrinkingContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.shrinkingContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shrinkingContentView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:CGRectGetHeight(self.shrinkingContentView.frame)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shrinkingContentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:@{ @"view" : self.shrinkingContentView }]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self hideEndCard:YES];
}

#pragma mark - Shrinking Layout

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];

    self.shrinkingContentView.frame = self.contentView.bounds;
    
    CGFloat scale = CGRectGetHeight(self.contentView.bounds) / CGRectGetWidth(self.contentView.bounds);
    self.shrinkingContentView.transform = CGAffineTransformMakeScale( scale, scale );
}

#pragma mark - Rotation

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.endCardViewController handleRotationToInterfaceOrientation:toInterfaceOrientation];
    
    self.shrinkingContentView.frame = self.bounds;
    
    // If we're in landscape, we need to add autolayout constraints to make sure the view set as
    // the `shrinkingContentView` will size to fit the full screen.  Otherwise we remove all constraints
    // so that transformations can be applied properly in `updateContentToShrinkingLayout` method.
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
        self.shrinkingContentView.transform = CGAffineTransformIdentity;
        self.shrinkingContentView.frame = self.shrinkingContentView.superview.bounds;
        [self.shrinkingContentView layoutIfNeeded];
    }
    else
    {
        self.shrinkingContentView.autoresizingMask = 0;
        [self.shrinkingContentView layoutIfNeeded];
    }
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:self.animationImageView];
}

#pragma mark - Public Methods

- (void)playAnimation
{
    self.animationImageView.animationImages = self.animationSequence;
    self.animationImageView.animationDuration = self.animationDuration;
    self.animationImageView.animationRepeatCount = self.repeatCount;
    [self.animationImageView startAnimating];
}

#pragma mark - End Card

- (BOOL)isEndCardShowing
{
    return self.endCardViewController != nil;
}

- (void)disableEndcardAutoplay
{
    [self.endCardViewController disableAutoplay];
}

- (void)showEndCardWithViewModel:(VEndCardModel *)model
{
    if ( self.endCardViewController == nil )
    {
        self.endCardViewController = [VEndCardViewController newWithDependencyManager:model.dependencyManager
                                                                                model:model
                                                                        minViewHeight:self.minSize.height
                                                                        maxViewHeight:self.maxSize.height];
        self.endCardViewController.delegate = self;
    }
    
    [self.contentView addSubview:self.endCardViewController.view];
    self.endCardViewController.view.frame = self.contentView.bounds;
    [self.contentView v_addFitToParentConstraintsToSubview:self.endCardViewController.view];
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.endCardViewController handleRotationToInterfaceOrientation:currentOrientation];
    [self.endCardViewController transitionIn];
}

- (void)hideEndCard
{
    [self hideEndCard:NO];
}

- (void)hideEndCard:(BOOL)cleanup
{
    if ( self.endCardViewController != nil )
    {
        [self.endCardViewController.view removeFromSuperview];
        if ( cleanup )
        {
            self.endCardViewController = nil;
        }
    }
}

#pragma mark - VEndCardViewControllerDelegate

- (void)replaySelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    [self.endCardDelegate replaySelectedFromEndCard:endCardViewController];
}

- (void)nextSelectedFromEndCard:(VEndCardViewController *)endCardViewController
{
    [self.endCardDelegate nextSelectedFromEndCard:endCardViewController];
}

- (void)actionCellSelected:(VEndCardActionCell *)actionCell atIndex:(NSUInteger)index
{
    [self.endCardDelegate actionCellSelected:actionCell atIndex:index];
}

@end
