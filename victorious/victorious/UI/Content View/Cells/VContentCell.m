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

@property (nonatomic, assign) CGSize maxSize;
@property (nonatomic, strong, readwrite) VEndCardViewController *endCardViewController;

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
    
    self.maxSize = self.frame.size;
    
    self.repeatCount = 1;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:self.animationImageView];
}

#pragma mark - Public Methodsx

- (void)playAnimation
{
    self.animationImageView.animationImages = self.animationSequence;
    self.animationImageView.animationDuration = self.animationDuration;
    self.animationImageView.animationRepeatCount = self.repeatCount;
    [self.animationImageView startAnimating];
}

#pragma mark - End Card

- (void)resetEndCardActions:(BOOL)animated
{
    if ( self.endCardViewController != nil )
    {
        [self.endCardViewController deselectActionsAnimated:animated];
    }
}

- (void)showEndCardWithViewModel:(VEndCardModel *)model
{
    if ( self.endCardViewController != nil )
    {
        [self.endCardViewController.view removeFromSuperview];
        self.endCardViewController = nil;
    }
    
    self.endCardViewController = [VEndCardViewController newWithDependencyManager:nil
                                                                            model:model
#warning This should be the same as VShrinkingContentLayoutMinimumContentHeight
                                                                    minViewHeight:125.0f
                                                                    maxViewHeight:self.maxSize.height];
    self.endCardViewController.delegate = self;
    [self.contentView addSubview:self.endCardViewController.view];
    self.endCardViewController.view.frame = self.contentView.bounds;
    [self.contentView v_addFitToParentConstraintsToSubview:self.endCardViewController.view];
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

- (void)actionSelectedFromEndCard:(VEndCardViewController *)endCardViewController atIndex:(NSUInteger)index userInfo:(NSDictionary *)userInfo
{
    [self.endCardDelegate actionSelectedFromEndCard:endCardViewController atIndex:index userInfo:userInfo];
}

@end
