//
//  VContentCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCell.h"
#import "UIVIew+AutoLayout.h"

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

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
    if (!self.animationImageView)
    {
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        animationImageView.backgroundColor = [UIColor clearColor];
        animationImageView.userInteractionEnabled = NO;
        self.animationImageView = animationImageView;
        [self.contentView addSubview:animationImageView];
    }
    
    // Set some initial/default values
    self.maxSize = self.frame.size;
    self.minSize = CGSizeMake( self.frame.size.width, 0.0f );
    
    self.repeatCount = 1;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if ( self.endCardViewController != nil )
    {
        [self.endCardViewController.view removeFromSuperview];
        self.endCardViewController = nil;
    }
}

#pragma mark - Rotation

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.endCardViewController handleRotationToInterfaceOrientation:toInterfaceOrientation];
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

- (void)showEndCardWithViewModel:(VEndCardModel *)model
{
    if ( self.endCardViewController == nil )
    {
        self.endCardViewController = [VEndCardViewController newWithDependencyManager:model.dependencyManager
                                                                                model:model
                                                                        minViewHeight:self.minSize.height
                                                                        maxViewHeight:self.maxSize.height];
        self.endCardViewController.delegate = self;
        [self.contentView addSubview:self.endCardViewController.view];
        self.endCardViewController.view.frame = self.contentView.bounds;
        [self.contentView v_addFitToParentConstraintsToSubview:self.endCardViewController.view];
    }
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.endCardViewController handleRotationToInterfaceOrientation:currentOrientation];
    [self.endCardViewController transitionIn];
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

- (void)actionCell:(VEndCardActionCell *)actionCell selectedWithIndex:(NSUInteger)index
{
    [self.endCardDelegate actionCell:actionCell selectedWithIndex:index];
}

@end
