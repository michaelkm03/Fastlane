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
@property (nonatomic, strong) UIImageView *answerAImageView;
@property (nonatomic, strong) UIImageView *answerBImageView;
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
    self.pollIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"D_pollOr"]];
    self.pollIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.pollIconImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.hasLayedOutViews)
    {
        [self v_addPintoTopBottomToSubview:self.answerAImageView];
        [self v_addPintoTopBottomToSubview:self.answerBImageView];
        
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
        
        self.hasLayedOutViews = YES;
    }
}

#pragma mark - Public Methods

- (void)setImageURL:(NSURL *)imageURL forPollAnswer:(VPollAnswer)pollAnswer
{
    switch (pollAnswer)
    {
        case VPollAnswerA:
            [self.answerAImageView fadeInImageAtURL:imageURL];
            break;
        case VPollAnswerB:
            [self.answerBImageView fadeInImageAtURL:imageURL];
            break;
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

@end
