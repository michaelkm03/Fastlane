//
//  VHermesActionView.m
//  victorious
//
//  Created by Michael Sena on 4/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHermesActionView.h"

// Stream Support
#import "VSequence+Fetcher.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VRepostButtonController.h"

// Action Bar
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"

static const CGFloat kActionButtonWidth = 30.0f;
static const CGFloat kLeadingActionButtonMargin = 15.0f;
static const CGFloat kInterActionButtonSpacing = 11.0f;

@interface VHermesActionView ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *gifButton;
@property (nonatomic, strong) UIButton *memeButton;
@property (nonatomic, strong) UIButton *repostButton;

@property (nonatomic, strong) VRepostButtonController *repostButtonController;

// Each view will be reused for a unique configuration (share only, share+repost, et)
@property (nonatomic, assign) BOOL hasLayedOutActionView;

@end

@implementation VHermesActionView

#pragma mark - Reuse Identifiers

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier
{
    NSMutableString *identifier = [baseIdentifier mutableCopy];
    
    [identifier appendString:@"share"];
    if ([sequence canRepost])
    {
        [identifier appendString:@"repost"];
    }
    if ([sequence canRemix])
    {
        [identifier appendString:@"meme"];
    }
    if ([sequence canRemix] && [sequence isVideo])
    {
        [identifier appendString:@"gif"];
    }
    
    return [NSString stringWithString:identifier];
}

#pragma mark - Property Accessors

- (UIButton *)shareButton
{
    if (_shareButton == nil)
    {
        _shareButton = [self actionButtonWithImage:[[UIImage imageNamed:@"B_stream_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                            action:@selector(share:)];
    }
    return _shareButton;
}

- (UIButton *)gifButton
{
    if (_gifButton == nil)
    {
        _gifButton = [self actionButtonWithImage:[[UIImage imageNamed:@"B_stream_gif"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                          action:@selector(gif:)];
    }
    return _gifButton;
}

- (UIButton *)memeButton
{
    if (_memeButton == nil)
    {
        _memeButton = [self actionButtonWithImage:[[UIImage imageNamed:@"B_stream_meme"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                           action:@selector(meme:)];
    }
    return _memeButton;
}

- (UIButton *)repostButton
{
    if (_repostButton == nil)
    {
        _repostButton = [self actionButtonWithImage:[[UIImage imageNamed:@"B_stream_repost"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                             action:@selector(repost:)];
    }
    return _repostButton;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    // configure
}

#pragma mark - Button Factory

- (UIButton *)actionButtonWithImage:(UIImage *)actionImage
                             action:(SEL)action
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [actionButton setImage:actionImage forState:UIControlStateNormal];
    actionButton.contentMode = UIViewContentModeScaleAspectFit;
    actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    actionButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    actionButton.tintColor = [UIColor whiteColor];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [actionButton v_addWidthConstraint:kActionButtonWidth];
    [actionButton v_addHeightConstraint:kActionButtonWidth];

    return actionButton;
}

@end

@implementation VHermesActionView (VUpdateHooks)

- (void)updateActionItemsOnBar:(VActionBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    if (actionBar == nil)
    {
        return;
    }
    
    if (self.hasLayedOutActionView)
    {
        return;
    }
    
    NSMutableArray *actionButtons = [[NSMutableArray alloc] init];
    
    [actionButtons addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingActionButtonMargin]];
    [actionButtons addObject:self.shareButton];

    if ([sequence canRepost])
    {
        [actionButtons addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionButtonSpacing]];
        [actionButtons addObject:self.repostButton];
    }
    
    if ([sequence canRemix])
    {
        [actionButtons addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionButtonSpacing]];
        [actionButtons addObject:self.memeButton];
    }
    
    if ([sequence canRemix] && [sequence isVideo])
    {
        [actionButtons addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionButtonSpacing]];
        [actionButtons addObject:self.gifButton];
    }

    [actionButtons addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    
    actionBar.actionItems = [NSArray arrayWithArray:actionButtons];
    self.hasLayedOutActionView = YES;
}

- (void)updateRepostButtonForSequence:(VSequence *)sequence
{
    [self.repostButtonController invalidate];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:[UIImage imageNamed:@"B_stream_repost-success"]
                                                                    unRepostedImage:[UIImage imageNamed:@"B_stream_repost"]];

}

@end