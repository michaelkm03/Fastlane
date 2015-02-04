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
@property (nonatomic, strong) CADisplayLink *displayLink;

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

- (void)dealloc
{
    if ( self.displayLink != nil )
    {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
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

- (void)setShrinkingContentView:(UIView *)shrinkingContentView
{
    _shrinkingContentView = shrinkingContentView;
    
    if ( _shrinkingContentView != nil )
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    else
    {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

- (void)update:(CADisplayLink *)displayLink
{
    const CGAffineTransform currentTransform = self.shrinkingContentView.transform;
    self.shrinkingContentView.transform = CGAffineTransformIdentity;
    const CGRect videoFrame = self.shrinkingContentView.frame;
    self.shrinkingContentView.transform = currentTransform;
    const CGRect currentFrame = [[self.contentView.layer presentationLayer] frame];
    
    const CGFloat translateY = 0; //(CGRectGetHeight(videoFrame) - CGRectGetHeight(currentFrame)) * 0.5f;
    const CGFloat scale = MIN( CGRectGetHeight(currentFrame) / CGRectGetHeight(videoFrame), 1.0f );
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate( transform, 0.0f, -translateY );
    transform = CGAffineTransformScale( transform, scale, scale );
    self.shrinkingContentView.transform = transform;
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

- (void)actionCellSelected:(VEndCardActionCell *)actionCell atIndex:(NSUInteger)index
{
    [self.endCardDelegate actionCellSelected:actionCell atIndex:index];
}

@end
