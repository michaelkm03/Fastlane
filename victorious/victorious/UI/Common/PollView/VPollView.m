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
    
    self.playButtonA = [[UIButton alloc] init];
    self.playButtonA.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playButtonA setImage:playIcon forState:UIControlStateNormal];
    self.playButtonA.userInteractionEnabled = NO;
    self.playButtonA.backgroundColor = [UIColor clearColor];
    self.playButtonA.userInteractionEnabled = NO;
    [self addSubview:self.playButtonA];
    
    self.playButtonB = [[UIButton alloc] init];
    self.playButtonB.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playButtonB setImage:playIcon forState:UIControlStateNormal];
    self.playButtonB.userInteractionEnabled = NO;
    self.playButtonB.backgroundColor = [UIColor clearColor];
    self.playButtonB.userInteractionEnabled = NO;
    [self addSubview:self.playButtonB];
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
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButtonA
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButtonA
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerAImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0 constant:0.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButtonB
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButtonB
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.answerBImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0 constant:0.0]];
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
