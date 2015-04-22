//
//  VCreationInfoContainer.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationInfoContainer.h"

// Libraries
#import <KVOController/FBKVOController.h>

// Dependencies
#import "VDependencyManager.h"

// Models
#import "VSequence+Fetcher.h"
#import "VUser+Fetcher.h"

// Formatters
#import "VLargeNumberFormatter.h"

// Views + Helpers
#import "UIView+Autolayout.h"

static const CGFloat kClockSize = 8.0f;
static const CGFloat kSpaceToCenterWhenTwoLines = 2.0f;
static const CGFloat kSpaceCreatorLabelToClockImageView = 4.0f;
static const CGFloat kSpaceClockImageViewToTimeSinceLabel = 3.0f;

@interface VCreationInfoContainer ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *parentUserLabel;
@property (nonatomic, strong) UIImageView *clockImageView;
@property (nonatomic, strong) UILabel *timeSinceLabel;

@property (nonatomic, strong) NSLayoutConstraint *centerCreatorLabelConstraint;
@property (nonatomic, strong) NSLayoutConstraint *creatorBottomToCenterConstraint;
@property (nonatomic, strong) NSLayoutConstraint *parentUserTopToCenterConstraint;

@property (nonatomic, assign) BOOL layedOutDefaultConstraints;

@end

@implementation VCreationInfoContainer

#pragma mark - Init

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
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    
    self.creatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.creatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.creatorLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.creatorLabel];
    
    self.parentUserLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.parentUserLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.parentUserLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.parentUserLabel];
    
    UIImage *clockImage = [[UIImage imageNamed:@"StreamDate"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.clockImageView = [[UIImageView alloc] initWithImage:clockImage];
    self.clockImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.clockImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clockImageView v_addWidthConstraint:kClockSize];
    [self.clockImageView v_addHeightConstraint:kClockSize];
    [self addSubview:self.clockImageView];

    self.timeSinceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeSinceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeSinceLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.timeSinceLabel];
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(100.0f, 44.0f);
}

- (void)updateConstraints
{
    NSDictionary *viewDictionary = @{
                                     @"creatorLabel":self.creatorLabel,
                                     @"parentUserLabel":self.parentUserLabel,
                                     @"clockImageView":self.clockImageView,
                                     @"timeSinceLabel":self.timeSinceLabel,
                                     };
    
    if (!self.layedOutDefaultConstraints)
    {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[creatorLabel]-kSpaceCreatorLabelToClockImageView-[clockImageView]-kSpaceClockImageViewToTimeSinceLabel-[timeSinceLabel]"
                                                                     options:kNilOptions
                                                                     metrics:@{@"kSpaceCreatorLabelToClockImageView": @(kSpaceCreatorLabelToClockImageView),
                                                                               @"kSpaceClockImageViewToTimeSinceLabel": @(kSpaceClockImageViewToTimeSinceLabel)}
                                                                       views:viewDictionary]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.clockImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.creatorLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeSinceLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.creatorLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[parentUserLabel]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        
        self.layedOutDefaultConstraints = YES;
    }
    
    if (self.parentUserLabel.text == nil)
    {
        // Center the creator label vertically
        [self removeConstraint:self.creatorBottomToCenterConstraint];
        [self removeConstraint:self.parentUserTopToCenterConstraint];
        self.centerCreatorLabelConstraint = [NSLayoutConstraint constraintWithItem:self.creatorLabel
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:0.0f];
        [self addConstraint:self.centerCreatorLabelConstraint];
    }
    else
    {
        // Distribute Creator/subtitle vertically
        
        [self removeConstraint:self.centerCreatorLabelConstraint];
        self.creatorBottomToCenterConstraint = [NSLayoutConstraint constraintWithItem:self.creatorLabel
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1.0f
                                                                            constant:-kSpaceToCenterWhenTwoLines];
        [self addConstraint:self.creatorBottomToCenterConstraint];
        self.parentUserTopToCenterConstraint = [NSLayoutConstraint constraintWithItem:self.parentUserLabel
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.0f
                                                                             constant:kSpaceToCenterWhenTwoLines];
        [self addConstraint:self.parentUserTopToCenterConstraint];
    }
    
    [super updateConstraints];
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    if (_sequence == sequence)
    {
        return;
    }
    
    if (_sequence.user != nil)
    {
        [self.KVOController unobserve:_sequence.user];
    }
    
    _sequence = sequence;
    
    [self updateWithSequence:_sequence];

    if (sequence.user != nil)
    {
        __weak typeof(self) welf = self;
        [self.KVOController observe:sequence.user
                            keyPaths:@[NSStringFromSelector(@selector(name))]
                            options:NSKeyValueObservingOptionNew
                              block:^(id observer, VUser *object, NSDictionary *change)
         {
             [welf updateWithSequence:_sequence];
         }];
    }
}

#pragma mark - Update UI

- (void)updateWithSequence:(VSequence *)sequence
{
    self.creatorLabel.text = [sequence originalPoster].name;
    self.parentUserLabel.text = [sequence parentUser].name;
#warning Update timeAgo label
    self.timeSinceLabel.text = @"5h";
    [self setNeedsUpdateConstraints];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
#warning RESTOEREME
    self.creatorLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.parentUserLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    self.timeSinceLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    
//    self.creatorLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
//    self.parentUserLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerAccentColorKey];
//    self.timeSinceLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
//    self.clockImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];

#warning Remove Me
    self.creatorLabel.textColor = [UIColor whiteColor];
    self.parentUserLabel.textColor = [UIColor whiteColor];
    self.timeSinceLabel.textColor = [UIColor whiteColor];
    self.clockImageView.tintColor = [UIColor whiteColor];
}

@end
