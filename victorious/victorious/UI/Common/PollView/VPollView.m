//
//  VPollView.m
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPollView.h"

// Views + Helpers
#import "UIView+AutoLayout.h"
#import "UIImageView+VLoadingAnimations.h"

@interface VPollView ()

@property (nonatomic, assign) BOOL hasLayedOutViews;
@property (nonatomic, strong) UIImageView *pollIconImageView;

@end

@implementation VPollView

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.answerAImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.answerAImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.answerAImageView];
    
    self.answerBImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.answerBImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.answerBImageView];
    
    // D_pollOr is the default 
    self.pollIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.pollIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.pollIconImageView];
    
    UIImage *playIcon = [UIImage imageNamed:@"play-btn-icon"];
    
    self.playIconA = [[UIImageView alloc] initWithImage:playIcon];
    self.playIconA.translatesAutoresizingMaskIntoConstraints = NO;
    self.playIconA.backgroundColor = [UIColor clearColor];
    [self addSubview:self.playIconA];
    
    self.playIconB = [[UIImageView alloc] initWithImage:playIcon];
    self.playIconB.translatesAutoresizingMaskIntoConstraints = NO;
    self.playIconB.backgroundColor = [UIColor clearColor];
    [self addSubview:self.playIconB];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.hasLayedOutViews)
    {
        [self v_addPinToTopBottomToSubview:self.answerAImageView];
        [self v_addPinToTopBottomToSubview:self.answerBImageView];
        [self.answerAImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.answerBImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        [self v_addCenterToParentContraintsToSubview:self.pollIconImageView];
        
        self.answerAImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.answerAImageView.clipsToBounds = YES;
        self.answerBImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.answerBImageView.clipsToBounds = YES;
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playIconA
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playIconA
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0 constant:0.0]];
        [self.playIconA addConstraint:[NSLayoutConstraint constraintWithItem:self.playIconA
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.playIconA
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0/1.0
                                                                    constant:0.0f]];
        
        CGFloat playIconMinimumSpacingToContainerBorder = 0.125 * CGRectGetWidth(self.bounds);
        
        [self v_addHorizontalMinimumSpacingToSubview:self.playIconA spacing:playIconMinimumSpacingToContainerBorder];
        [self v_addVerticalMinimumSpacingToSubview:self.playIconA spacing:playIconMinimumSpacingToContainerBorder];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playIconB
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playIconB
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0 constant:0.0]];
        [self.playIconB addConstraint:[NSLayoutConstraint constraintWithItem:self.playIconB
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.playIconB
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0/1.0
                                                                    constant:0.0f]];
        [self v_addHorizontalMinimumSpacingToSubview:self.playIconB spacing:playIconMinimumSpacingToContainerBorder];
        [self v_addHorizontalMinimumSpacingToSubview:self.playIconB spacing:playIconMinimumSpacingToContainerBorder];
        
        self.hasLayedOutViews = YES;
    }
}

- (void)setPollIcon:(UIImage *)pollIcon
{
    self.pollIconImageView.image = pollIcon;
}

- (UIImage *)pollIcon
{
    return self.pollIconImageView.image;
}

- (void)setPollIconHidden:(BOOL)hidden animated:(BOOL)animated
{
    void (^animations)() = ^
    {
        self.pollIconImageView.alpha = hidden ? 0.0 : 1.0f;
        CGAffineTransform smallScale = CGAffineTransformMakeScale( 0.1f, 0.1f );
        self.pollIconImageView.transform = hidden ? smallScale : CGAffineTransformIdentity;
    };
    if ( animated )
    {
        [UIView animateWithDuration:0.4f
                              delay:hidden ? 0.0 : 0.2f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0.5f
                            options:kNilOptions
                         animations:animations
                         completion:nil];
    }
    else
    {
        animations();
    }
}

@end
