//
//  VProgressBarView.m
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProgressBarView.h"

@interface VProgressBarView ()

@property (nonatomic, strong) UIView *completedProgressView;

@end

@implementation VProgressBarView

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
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
    self.backgroundColor = [UIColor clearColor];
    
    self.completedProgressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, CGRectGetHeight(self.bounds))];
    self.completedProgressView.backgroundColor = self.progressColor;
    [self addSubview:self.completedProgressView];
}

#pragma mark - Property Accessor

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.completedProgressView.backgroundColor = _progressColor;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.completedProgressView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds) * progress, CGRectGetHeight(self.bounds));
}

#pragma mark - Public Methods

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    _progress = progress;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
    {
        self.completedProgressView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds) * progress, CGRectGetHeight(self.bounds));
    }
                     completion:nil];
}

@end
