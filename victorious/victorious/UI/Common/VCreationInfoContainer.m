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
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

// Formatters
#import "VLargeNumberFormatter.h"
#import "NSDate+timeSince.h"

// Views + Helpers
#import "UIView+Autolayout.h"

static const CGFloat kClockSize = 8.5f;
static const CGFloat kSpaceToCenterWhenTwoLines = 2.5f;
static const CGFloat kSpaceCreatorLabelToClockImageView = 4.0f;
static const CGFloat kSpaceClockImageViewToTimeSinceLabel = 3.0f;
static const CGFloat kDefaultHeight = 44.0f;

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
    self.parentUserLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(selectedUser:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - UIView

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
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeSinceLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[parentUserLabel]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        
        self.layedOutDefaultConstraints = YES;
    }
    
    [self removeConstraint:self.creatorBottomToCenterConstraint];
    [self removeConstraint:self.parentUserTopToCenterConstraint];
    [self removeConstraint:self.centerCreatorLabelConstraint];
    if (self.parentUserLabel.text == nil || self.parentUserLabel.attributedText == nil || [self.parentUserLabel.text isEqualToString:@""])
    {
        // Center the creator label vertically
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
    
    if ([self v_internalHeightConstraint] == nil)
    {
        [self v_addHeightConstraint:kDefaultHeight];
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

#pragma mark - Target/Action

- (void)selectedUser:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.delegate creationInfoContainer:self
                  selectedUserOnSequence:self.sequence];
}

#pragma mark - Update UI

- (void)updateWithSequence:(VSequence *)sequence
{
    self.creatorLabel.text = [sequence displayOriginalPoster].name;
    [self updateParentUserLabelWithSequence:sequence];
    self.timeSinceLabel.text = [sequence.releasedAt timeSince];
    [self setNeedsUpdateConstraints];
}

- (void)updateParentUserLabelWithSequence:(VSequence *)sequence
{
    // Format repost / remix string
    NSString *parentUserString = sequence.displayParentUser.name ?: @"";
    NSString *formattedString = nil;
    
    if (self.sequence.isRepost.boolValue && self.sequence.parentUser != nil)
    {
        NSUInteger repostCount = [self.sequence.repostCount unsignedIntegerValue];
        if ( repostCount == 0 )
        {
            formattedString = [NSString stringWithFormat:NSLocalizedString(@"repostedByFormat", nil), parentUserString];
        }
        else if ( repostCount == 1 )
        {
            formattedString = [NSString stringWithFormat:NSLocalizedString(@"doubleRepostedByFormat", nil), parentUserString];
        }
        else
        {
            formattedString = [NSString stringWithFormat:NSLocalizedString(@"multipleRepostedByFormat", nil), parentUserString, [self.sequence.repostCount unsignedLongValue]];
        }
    }
    
    if (self.sequence.isRemix.boolValue && self.sequence.parentUser != nil)
    {
        NSString *formatString = NSLocalizedString(@"remixedFromFormat", nil);
        if ([[[[self.sequence firstNode] mp4Asset] playerControlsDisabled] boolValue])
        {
            formatString = NSLocalizedString(@"giffedFromFormat", nil);
        }
        formattedString = [NSString stringWithFormat:formatString, parentUserString];
    }
    
    if (formattedString != nil && self.dependencyManager != nil)
    {
        NSRange range = [formattedString rangeOfString:parentUserString];
        NSDictionary *attributes = @{
                                     NSFontAttributeName: self.parentUserLabel.font,
                                     NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey],
                                     };
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:formattedString
                                                                                             attributes:attributes];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                                 range:range];
        self.parentUserLabel.attributedText = attributedString;
    }
    else
    {
        self.parentUserLabel.text = nil;
        self.parentUserLabel.attributedText = nil;
    }
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if (_dependencyManager == dependencyManager)
    {
        return;
    }
    
    _dependencyManager = dependencyManager;

    self.creatorLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.parentUserLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    self.timeSinceLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    
    self.creatorLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.parentUserLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.timeSinceLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.clockImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
}

#pragma mark - VActionBarFlexibleWidth

- (BOOL)canApplyFlexibleWidth
{
    return YES;
}

@end
