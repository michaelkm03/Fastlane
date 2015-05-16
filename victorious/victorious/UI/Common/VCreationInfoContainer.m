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
#import <CCHLinkTextView/CCHLinkGestureRecognizer.h>

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
#import "UIColor+VBrightness.h"
#import "VStreamLabel.h"

// Respdoner Chain
#import "VSequenceActionsDelegate.h"

static const CGFloat kClockSize = 8.5f;
static const CGFloat kSpaceCreatorLabelToClockImageView = 4.0f;
static const CGFloat kSpaceClockImageViewToTimeSinceLabel = 3.0f;
static const CGFloat kDefaultHeight = 44.0f;
static const CGFloat kVerticalPaddingToCenterLabels = 0.0f;
static const CGFloat kHorizontalHitPadding = 44.0f;

@interface VCreationInfoContainer () <VStreamLabelDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@property (nonatomic, strong) VStreamLabel *creatorLabel;
@property (nonatomic, strong) VStreamLabel *parentUserLabel;
@property (nonatomic, strong) VStreamLabel *otherPostersLabel;
@property (nonatomic, strong) UIImageView *clockImageView;
@property (nonatomic, strong) UILabel *timeSinceLabel;

@property (nonatomic, strong) NSArray *singleLineConstraints;
@property (nonatomic, strong) NSArray *multiLineConstraints;

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
    
    self.creatorLabel = [[VStreamLabel alloc] initWithFrame:CGRectZero];
    self.creatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.creatorLabel.textAlignment = NSTextAlignmentLeft;
    self.creatorLabel.delegate = self;
    [self addSubview:self.creatorLabel];
    
    self.parentUserLabel = [[VStreamLabel alloc] initWithFrame:CGRectZero];
    self.parentUserLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.parentUserLabel.textAlignment = NSTextAlignmentLeft;
    self.parentUserLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.parentUserLabel.delegate = self;
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
    
    self.otherPostersLabel = [[VStreamLabel alloc] initWithFrame:CGRectZero];
    self.otherPostersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.otherPostersLabel.textAlignment = NSTextAlignmentLeft;
    self.otherPostersLabel.delegate = self;
    [self addSubview:self.otherPostersLabel];
}

#pragma mark - UIView

- (void)updateConstraints
{
    NSDictionary *viewDictionary = @{
                                     @"creatorLabel":self.creatorLabel,
                                     @"parentUserLabel":self.parentUserLabel,
                                     @"clockImageView":self.clockImageView,
                                     @"timeSinceLabel":self.timeSinceLabel,
                                     @"otherPostersLabel":self.otherPostersLabel
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
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[parentUserLabel][otherPostersLabel]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.otherPostersLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        self.layedOutDefaultConstraints = YES;
    }
    
    if ([self.sequence displayParentUser].name.length > 0)
    {
        // Distribute Creator/subtitle vertically
        if (self.singleLineConstraints != nil)
        {
            [NSLayoutConstraint deactivateConstraints:self.singleLineConstraints];
        }
        
        if (self.multiLineConstraints == nil)
        {
            NSMutableArray *multiLineConstraints = [[NSMutableArray alloc] init];
            [multiLineConstraints addObject:[NSLayoutConstraint constraintWithItem:self.creatorLabel
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:-kVerticalPaddingToCenterLabels]];
            [multiLineConstraints addObject:[NSLayoutConstraint constraintWithItem:self.parentUserLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:kVerticalPaddingToCenterLabels]];
            [multiLineConstraints addObject:[NSLayoutConstraint constraintWithItem:self.otherPostersLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:kVerticalPaddingToCenterLabels]];

            self.multiLineConstraints = [NSArray arrayWithArray:multiLineConstraints];
            [self addConstraints:self.multiLineConstraints];
        }
        [NSLayoutConstraint activateConstraints:self.multiLineConstraints];
    }
    else
    {
        // Center the creator label vertically
        if (self.multiLineConstraints != nil)
        {
            [NSLayoutConstraint deactivateConstraints:self.multiLineConstraints];
        }
        
        if (self.singleLineConstraints == nil)
        {
            self.singleLineConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[creatorLabel]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:@{@"creatorLabel":self.creatorLabel}];
            [self addConstraints:self.singleLineConstraints];
        }
        [NSLayoutConstraint activateConstraints:self.singleLineConstraints];
    }
    
    if ([self v_internalHeightConstraint] == nil)
    {
        NSLayoutConstraint *defaultHeight = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0f
                                                                          constant:kDefaultHeight];
        defaultHeight.priority = UILayoutPriorityDefaultLow;
        [self addConstraint:defaultHeight];
    }
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.sequence.parentUser.name > 0)
    {
        // Multiline hit insets
        CGFloat creatorTopPadding = CGRectGetMinY(self.creatorLabel.frame);
        UIEdgeInsets creatorHitInsets = UIEdgeInsetsMake(-creatorTopPadding, 0.0f, -kVerticalPaddingToCenterLabels, -kHorizontalHitPadding);
        self.creatorLabel.hitInsets = creatorHitInsets;
        CGFloat parentUserBottomPadding = CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.parentUserLabel.frame);
        self.parentUserLabel.hitInsets = UIEdgeInsetsMake(-kVerticalPaddingToCenterLabels, 0.0f, -parentUserBottomPadding, -kHorizontalHitPadding);
    }
    else
    {
        // Single line hit insets
        self.creatorLabel.hitInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 44.0f);
    }
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

- (void)setShouldShowTimeSince:(BOOL)shouldShowTimeSince
{
    _shouldShowTimeSince = shouldShowTimeSince;
    
    self.clockImageView.hidden = !shouldShowTimeSince;
    self.timeSinceLabel.hidden = !shouldShowTimeSince;
}

#pragma mark - Action Forwarding

- (void)selectedUser:(VUser *)user
{
    UIResponder<VSequenceActionsDelegate> *targetForUserSelection = [self targetForAction:@selector(selectedUser:onSequence:fromView:)
                                                                               withSender:self];
    if (targetForUserSelection == nil)
    {
        NSAssert(false, @"We need an object in the responder chain for user selection.");
    }
    [targetForUserSelection selectedUser:user
                              onSequence:self.sequence
                                fromView:self];
}

- (void)showReposters
{
    UIResponder<VSequenceActionsDelegate> *targetForReposter = [self targetForAction:@selector(showRepostersForSequence:)
                                                                          withSender:self];
    if (targetForReposter == nil)
    {
        NSAssert(false, @"We need an object in the responder chain for reposters selection.");
    }
    [targetForReposter showRepostersForSequence:self.sequence];
}

#pragma mark - Internal Methods

- (UIColor *)highlightedColorForColor:(UIColor *)color
{
    UIColor *highlightedColor = nil;
    
    switch (color.v_colorLuminance)
    {
        case VColorLuminanceBright:
            highlightedColor = [color v_colorDarkenedBy:0.5f];
            break;
        case VColorLuminanceDark:
            highlightedColor = [color v_colorLightenedBy:0.5f];
            break;
            
    }
    return highlightedColor;
}

- (NSAttributedString *)attributedCreatorStringHighlighted:(BOOL)highlighted
{
    if (self.sequence.displayOriginalPoster.name.length == 0)
    {
        return nil;
    }
    
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    if (highlighted)
    {
        textColor = [self highlightedColorForColor:textColor];
    }
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: textColor,
                                 NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey]};

    return [[NSAttributedString alloc] initWithString:self.sequence.displayOriginalPoster.name
                                           attributes:attributes];
}

- (NSAttributedString *)attributedParentStringHightlighted:(BOOL)highlighted
{
    NSString *parentUserString = self.sequence.displayParentUser.name ?: @"";
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
            formattedString = [NSString stringWithFormat:NSLocalizedString(@"repostedByFormat", nil), parentUserString];
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
        UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        if (highlighted)
        {
            textColor = [self highlightedColorForColor:textColor];
        }
        NSDictionary *attributes = @{
                                     NSFontAttributeName: [_dependencyManager fontForKey:VDependencyManagerLabel2FontKey],
                                     NSForegroundColorAttributeName: textColor,
                                     };
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:formattedString
                                                                                             attributes:attributes];
        
        NSRange range = [formattedString rangeOfString:parentUserString];
        UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        UIColor *userTextColor = highlighted ? [linkColor v_colorDarkenedBy:0.15f] : linkColor;
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:userTextColor
                                 range:range];
        return attributedString;
    }
    else
    {
        return nil;
    }
}

- (NSAttributedString *)othersFormattedStringHighlighted:(BOOL)highlighted
{
    NSAttributedString *localizedOthersString = nil;
    if (self.sequence.isRepost.boolValue && self.sequence.parentUser != nil)
    {
        NSUInteger repostCount = [self.sequence.repostCount unsignedIntegerValue];
        if (repostCount > 1)
        {
            NSString *baseString = [NSString stringWithFormat:NSLocalizedString(@"+ %lu others", @""), (unsigned long)repostCount];
            UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
            if (highlighted)
            {
                textColor = [self highlightedColorForColor:textColor];
            }
            localizedOthersString = [[NSAttributedString alloc] initWithString:baseString
                                                                    attributes:@{NSFontAttributeName : [_dependencyManager fontForKey:VDependencyManagerLabel2FontKey],
                                                                                 NSForegroundColorAttributeName: textColor}];
        }
    }
    return localizedOthersString;
}

- (void)updateWithSequence:(VSequence *)sequence
{
    
    [self.creatorLabel setAttributedText:[self attributedCreatorStringHighlighted:NO]
                     forStreamLabelState:VStreamLabelStateDefault];
    [self.creatorLabel setAttributedText:[self attributedCreatorStringHighlighted:YES]
                     forStreamLabelState:VStreamLabelStateHighlighted];
    [self.parentUserLabel setAttributedText:[self attributedParentStringHightlighted:NO]
                        forStreamLabelState:VStreamLabelStateDefault];
    [self.parentUserLabel setAttributedText:[self attributedParentStringHightlighted:YES]
                        forStreamLabelState:VStreamLabelStateHighlighted];
    [self.otherPostersLabel setAttributedText:[self othersFormattedStringHighlighted:NO]
                          forStreamLabelState:VStreamLabelStateDefault];
    
    self.timeSinceLabel.text = [sequence.releasedAt timeSince];
    [self setNeedsUpdateConstraints];
}

#pragma mark - VStreamLabelDelegate

- (void)selectedStreamLabel:(VStreamLabel *)streamLabel
{
    if (streamLabel == self.creatorLabel)
    {
        [self selectedUser:[self.sequence displayOriginalPoster]];
    }
    else if (streamLabel == self.parentUserLabel)
    {
        [self selectedUser:[self.sequence displayParentUser]];
    }
    else if (streamLabel == self.otherPostersLabel)
    {
        [self showReposters];
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

    self.timeSinceLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.timeSinceLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.clockImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
}

#pragma mark - VActionBarFlexibleWidth

- (BOOL)canApplyFlexibleWidth
{
    return YES;
}

@end
