//
//  VEndCardAnimator.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardAnimator.h"
#import "VEndCardActionCell.h"
#import "VEndCardViewController.h"
#import "VEndCardBannerViewController.h"

/**
 @see http://gizma.com/easing/
 */
static CGFloat easeInQuint( CGFloat t, CGFloat b, CGFloat c, CGFloat d )
{
    t /= d;
    return c * t * t * t * t * t + b;
};


@interface VEndCardAnimator ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextVideoBannerTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *nextVideoBannerView;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UILabel *replayLabel;
@property (nonatomic, strong) NSTimer *replayButtonTimer;
@property (nonatomic, assign) CGFloat nextVideoBannerMaxTrailing;
@property (nonatomic, assign, readwrite) VEndCardAnimationState state;
@property (nonatomic, assign) CGFloat replayButtonMaxAlpha;

@end

@implementation VEndCardAnimator

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
    [self.replayButtonTimer invalidate];
}

#pragma mark - Public transition controls

- (void)transitionOutAllWithBackground:(BOOL)withBackground completion:(void(^)())completion
{
    if ( ![self canTransitionOut] )
    {
        return;
    }
    
    self.state = VEndCardAnimationStateIsTransitioningOut;
    
    [self transitionOutActions];
    [self setReplayButtonVisible:NO animated:YES];
    if ( withBackground )
    {
        [self setBackgroundVisible:NO animated:YES];
    }
    
    __typeof(self) __weak welf = self;
    [self setNextVideoBannerVisible:NO animated:YES completion:^
     {
         welf.state = VEndCardAnimationStateDidTransitionOut;
         if ( completion != nil )
         {
             completion();
         }
     }];
}

- (void)transitionInAllWithCompletion:(void(^)())completion
{
    if ( ![self canTransitionIn] )
    {
        return;
    }
    
    self.state = VEndCardAnimationStateIsTransitioningIn;
    
    [self transitionInActions];
    [self setReplayButtonVisible:YES animated:YES];
    [self setBackgroundVisible:YES animated:YES];
    
    __typeof(self) __weak welf = self;
    [self setNextVideoBannerVisible:YES animated:YES completion:^
     {
         welf.state = VEndCardAnimationStateDidTransitionIn;
         if ( completion != nil )
         {
             completion();
         }
     }];
}

- (void)reset
{
    self.state = VEndCardAnimationStateDidTransitionOut;
    self.replayButton.alpha = 0.0f;
    self.replayLabel.alpha = 0.0f;
    self.replayButtonMaxAlpha = 1.0f;
    self.collectionView.hidden = YES;
    self.nextVideoBannerMaxTrailing = self.nextVideoBannerTrailingConstraint.constant;
    self.nextVideoBannerTrailingConstraint.constant = -CGRectGetWidth( self.nextVideoBannerView.frame );
    [self.nextVideoBannerView.superview layoutIfNeeded];
}

#pragma mark - Background setter (blur effect)

- (void)setBackgroundView:(UIView *)backgroundView
{
    _backgroundView = backgroundView;
    _backgroundView.alpha = 0.0f;
}

#pragma mark - State management

- (BOOL)canTransitionIn
{
    return self.state != VEndCardAnimationStateDidTransitionIn && self.state != VEndCardAnimationStateDidTransitionIn;
}

- (BOOL)canTransitionOut
{
    return self.state != VEndCardAnimationStateDidTransitionOut && self.state != VEndCardAnimationStateDidTransitionOut;
}

#pragma mark - Timer-based animations

- (void)setExpandedRatio:(CGFloat)expandedRatio
{
    _expandedRatio = easeInQuint( expandedRatio, 0.0f, 1.0f, 1.0f );
    self.replayButtonMaxAlpha = _expandedRatio;
    self.nextVideoBannerView.alpha = _expandedRatio;
    
    if ( self.state == VEndCardAnimationStateDidTransitionIn )
    {
        self.replayButton.alpha = self.replayButtonMaxAlpha;
    }
    
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VEndCardActionCell *cell, NSUInteger idx, BOOL *stop)
    {
        [cell setTitleAlpha:_expandedRatio];
    }];
}

- (void)playReplayButtonRotationAnimation:(id)sender
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 ];
    rotationAnimation.duration = 1.2f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.replayButton.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark - Transition animations

- (void)transitionInActions
{
    self.collectionView.hidden = NO;
    NSTimeInterval delay = 0.3f;
    NSTimeInterval offset = 0.1f;
    NSTimeInterval totalTime = offset * (CGFloat)self.collectionView.visibleCells.count;
    
    [[self sortedVisibleCellsFromCollectionView:self.collectionView] enumerateObjectsUsingBlock:^(VEndCardActionCell *cell, NSUInteger idx, BOOL *stop)
     {
         [cell transitionInWithDuration: 0.25f delay:delay + totalTime - ((CGFloat)idx) * offset];
     }];
}

- (void)transitionOutActions
{
    NSTimeInterval delay = 0.0f;
    NSTimeInterval offset = 0.1f;
    
    void (^completion)(BOOL finished) = ^void (BOOL finished)
    {
        self.collectionView.hidden = YES;
    };
    
    [[self sortedVisibleCellsFromCollectionView:self.collectionView] enumerateObjectsUsingBlock:^(VEndCardActionCell *cell, NSUInteger idx, BOOL *stop)
     {
         BOOL shouldAddCompletion = (idx == self.collectionView.visibleCells.count - 1);
         [cell transitionOutWithDuration:0.25f delay:delay + ((CGFloat)idx) * offset completion:shouldAddCompletion ? completion : nil];
     }];
    
}
            
- (NSArray *)sortedVisibleCellsFromCollectionView:(UICollectionView *)collectionView
{
    return [collectionView.visibleCells sortedArrayWithOptions:kNilOptions
                            usingComparator:^NSComparisonResult(VEndCardActionCell *cell1, VEndCardActionCell *cell2)
                            {
                                return [@(CGRectGetMinX(cell1.frame)) compare:@(CGRectGetMinX(cell2.frame))];
                            }];
}

- (void)setNextVideoBannerVisible:(BOOL)visible animated:(BOOL)animated completion:(void(^)())completion
{
    void (^animations)() = ^void
    {
        self.nextVideoBannerTrailingConstraint.constant = self.nextVideoBannerMaxTrailing;
        [self.nextVideoBannerView.superview layoutIfNeeded];
    };
    
    if ( !animated )
    {
        animations();
        completion();
    }
    else
    {
        const NSUInteger numActions = [self.collectionView numberOfItemsInSection:0];
        const NSTimeInterval visibleDelay = 0.25f + (0.25f * numActions);
        
        [UIView animateWithDuration:visible ? 0.75f : 0.4f
                              delay:visible ? visibleDelay : 0.0f
             usingSpringWithDamping:visible ? 0.7 : 1.0f
              initialSpringVelocity:0.6
                            options:kNilOptions animations:^
         {
             CGFloat hiddenValue = -CGRectGetWidth( self.nextVideoBannerView.frame );
             CGFloat visibleValue = self.nextVideoBannerMaxTrailing;
             self.nextVideoBannerTrailingConstraint.constant = visible ? visibleValue : hiddenValue;
             [self.nextVideoBannerView.superview layoutIfNeeded];
         }
                         completion:^(BOOL finished)
         {
             completion();
         }];
    }
}

- (void)setReplayButtonVisible:(BOOL)visible animated:(BOOL)animated
{
    void (^animations)() = ^
    {
        self.replayButton.alpha = visible ? self.replayButtonMaxAlpha : 0.0f;
        self.replayLabel.alpha = visible ? self.replayButtonMaxAlpha : 0.0f;
    };
    
    if ( !animated )
    {
        animations();
    }
    else
    {
        [UIView animateWithDuration:0.4f
                              delay:visible ? 1.3f : 0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:animations
                         completion:nil];
    }
    
    [self.replayButtonTimer invalidate];
    if ( visible )
    {
        self.replayButtonTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                                  target:self
                                                                selector:@selector(playReplayButtonRotationAnimation:)
                                                                userInfo:nil
                                                                 repeats:YES];
    }
}

- (void)setBackgroundVisible:(BOOL)visible animated:(BOOL)animated
{
    if ( self.backgroundView == nil )
    {
        return;
    }
    
    void (^animations)() = ^void
    {
        self.backgroundView.alpha = visible ? 1.0f : 0.0f;
    };
    
    if ( !animated )
    {
        animations();
    }
    else
    {
        [UIView animateWithDuration:visible ? 0.3f : 0.4f
                              delay:visible ? 0.0f : 0.1f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:animations
                         completion:nil];
    }
}

@end
