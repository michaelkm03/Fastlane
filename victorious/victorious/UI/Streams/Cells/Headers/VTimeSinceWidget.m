//
//  VTimeSinceWidget.m
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTimeSinceWidget.h"

// Dependencies
#import "VDependencyManager.h"

// Models
#import "VSequence+Fetcher.h"

// Views + Helpers
#import "UIView+AutoLayout.h"

// Formatters
#import "VLargeNumberFormatter.h"
#import "NSDate+timeSince.h"

static const CGFloat kClockSize = 8.5f;

@interface VTimeSinceWidget ()

@property (nonatomic, strong) UIImageView *clockImageView;
@property (nonatomic, strong) UILabel *timeSinceLabel;
@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@end

@implementation VTimeSinceWidget

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

- (void)sharedInit
{
    UIImage *clockImage = [[UIImage imageNamed:@"StreamDate"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _clockImageView = [[UIImageView alloc] initWithImage:clockImage];
    _clockImageView.contentMode = UIViewContentModeScaleAspectFit;
    _clockImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_clockImageView v_addWidthConstraint:kClockSize];
    [_clockImageView v_addHeightConstraint:kClockSize];
    [self addSubview:self.clockImageView];
    
    _timeSinceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeSinceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeSinceLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.timeSinceLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_clockImageView][_timeSinceLabel]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_clockImageView, _timeSinceLabel)]];
    [self v_addCenterVerticallyConstraintsToSubview:_clockImageView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_timeSinceLabel]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_clockImageView, _timeSinceLabel)]];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.timeSinceLabel.text = [sequence.releasedAt timeSince];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    self.timeSinceLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.timeSinceLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.clockImageView.tintColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
}

@end
