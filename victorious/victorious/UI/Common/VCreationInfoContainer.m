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

// Respdoner Chain
#import "VSequenceActionsDelegate.h"

static const CGFloat kClockSize = 8.5f;
static const CGFloat kSpaceCreatorLabelToClockImageView = 4.0f;
static const CGFloat kSpaceClockImageViewToTimeSinceLabel = 3.0f;
static const CGFloat kDefaultHeight = 44.0f;

@interface VCreationInfoContainer () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *parentUserLabel;
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
    
    CCHLinkGestureRecognizer *originaluserGesture = [[CCHLinkGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(recognizedGesture:)];
    originaluserGesture.delegate = self;
    originaluserGesture.minimumPressDuration = HUGE_VALF;
    [self.creatorLabel addGestureRecognizer:originaluserGesture];
    
    CCHLinkGestureRecognizer *parentUserGesture = [[CCHLinkGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(recognizedGesture:)];

    parentUserGesture.delegate = self;
    parentUserGesture.minimumPressDuration = HUGE_VALF;
    [self.parentUserLabel addGestureRecognizer:parentUserGesture];
    
    self.parentUserLabel.userInteractionEnabled = YES;
    self.creatorLabel.userInteractionEnabled = YES;
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
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[parentUserLabel]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:viewDictionary]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.parentUserLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        self.layedOutDefaultConstraints = YES;
    }
    
    if (self.parentUserLabel.text == nil || self.parentUserLabel.attributedText == nil || [self.parentUserLabel.text isEqualToString:@""])
    {
        // Center the creator label vertically
        if (self.multiLineConstraints)
        {
            [NSLayoutConstraint deactivateConstraints:self.multiLineConstraints];
        }

        if (!self.singleLineConstraints)
        {
            self.singleLineConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[creatorLabel]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:@{@"creatorLabel":self.creatorLabel}];
            [self addConstraints:self.singleLineConstraints];
        }
        [NSLayoutConstraint activateConstraints:self.singleLineConstraints];
    }
    else
    {
        // Distribute Creator/subtitle vertically
        if (self.singleLineConstraints)
        {
            [NSLayoutConstraint deactivateConstraints:self.singleLineConstraints];
        }

        if (!self.multiLineConstraints)
        {
            NSMutableArray *multiLineConstraints = [[NSMutableArray alloc] init];
            [multiLineConstraints addObject:[NSLayoutConstraint constraintWithItem:self.creatorLabel
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0f
                                                                                 constant:0.0f]];
            [multiLineConstraints addObject:[NSLayoutConstraint constraintWithItem:self.parentUserLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
            [multiLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_creatorLabel]"
                                                                                              options:kNilOptions
                                                                                              metrics:nil
                                                                                                views:NSDictionaryOfVariableBindings(_creatorLabel)]];
            [multiLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_parentUserLabel]|"
                                                                                              options:kNilOptions
                                                                                              metrics:nil
                                                                                                views:NSDictionaryOfVariableBindings(_parentUserLabel)]];
            self.multiLineConstraints = [NSArray arrayWithArray:multiLineConstraints];
            [self addConstraints:self.multiLineConstraints];
        }
        [NSLayoutConstraint activateConstraints:self.multiLineConstraints];
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

- (void)setShouldShowTimeSince:(BOOL)shouldShowTimeSince
{
    _shouldShowTimeSince = shouldShowTimeSince;
    
    self.clockImageView.hidden = !shouldShowTimeSince;
    self.timeSinceLabel.hidden = !shouldShowTimeSince;
}

#pragma mark - Target/Action

- (void)recognizedGesture:(CCHLinkGestureRecognizer *)gestureRecognizer
{
    BOOL gestureSucceeded = YES;
    switch (gestureRecognizer.result)
    {
        case CCHLinkGestureRecognizerResultTap:
        case CCHLinkGestureRecognizerResultLongPress:
        case CCHLinkGestureRecognizerResultUnknown:
            if (gestureRecognizer.view == self.parentUserLabel)
            {
                self.parentUserLabel.attributedText = [self attributedParentStringHightlighted:YES];
            }
            else
            {
                self.creatorLabel.textColor = [self colorForCreatorLabelTextHighlighted:YES];
            }
            break;
        case CCHLinkGestureRecognizerResultFailed:
            if (gestureRecognizer.view == self.parentUserLabel)
            {
                self.parentUserLabel.attributedText = [self attributedParentStringHightlighted:NO];
            }
            else
            {
                self.creatorLabel.textColor = [self colorForCreatorLabelTextHighlighted:NO];
            }
            gestureSucceeded = NO;
            break;
    }
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateEnded:
            if (gestureSucceeded)
            {
                self.parentUserLabel.attributedText = [self attributedParentStringHightlighted:NO];
                self.creatorLabel.textColor = [self colorForCreatorLabelTextHighlighted:NO];
                VUser *selectedUser;
                if (gestureRecognizer.view == self.parentUserLabel)
                {
                    selectedUser = self.sequence.displayParentUser;
                }
                else
                {
                    selectedUser = self.sequence.displayOriginalPoster;
                }
                [self selectedUser:selectedUser];
            }
            break;
        default:
            break;
    }
}

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

#pragma mark - Internal Methods

- (UIColor *)colorForCreatorLabelTextHighlighted:(BOOL)highlighted
{
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    if (!highlighted)
    {
        return textColor;
    }
    switch (textColor.v_colorLuminance)
    {
        case VColorLuminanceBright:
            return [textColor v_colorDarkenedBy:0.5f];
        case VColorLuminanceDark:
            return [textColor v_colorLightenedBy:0.5f];
    }
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
#warning TODO: Move +x others to a separate label (for separate gesture recognition)
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
        NSDictionary *attributes = @{
                                     NSFontAttributeName: self.parentUserLabel.font,
                                     NSForegroundColorAttributeName: [self colorForCreatorLabelTextHighlighted:highlighted]
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

- (void)updateWithSequence:(VSequence *)sequence
{
    self.creatorLabel.text = [sequence displayOriginalPoster].name;
    self.parentUserLabel.attributedText = [self attributedParentStringHightlighted:NO];
    self.timeSinceLabel.text = [sequence.releasedAt timeSince];
    [self setNeedsUpdateConstraints];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint locationInView = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(CGRectInset(self.parentUserLabel.frame, -10.0f, -10.0f), locationInView) ||
        CGRectContainsPoint(CGRectInset(self.creatorLabel.frame, -10.0f, -10.0f), locationInView))
    {
        return YES;
    }
    return NO;
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
