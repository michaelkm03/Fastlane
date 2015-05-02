//
//  VInsetActionView.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetActionView.h"

// Frameworks
#import <FBKVOController.h>

// Dependencies
#import "VDependencyManager.h"

// Stream Support
#import "VSequence+Fetcher.h"

// Action Bar
#import "VActionBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VRoundedBackgroundButton.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VLargeNumberFormatter.h"
#import "VRepostButtonController.h"

static const CGFloat kActionButtonWidth = 44.0f;

@interface VInsetActionView ()

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *gifButton;
@property (nonatomic, strong) UIButton *memeButton;
@property (nonatomic, strong) UIButton *repostButton;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VRepostButtonController *repostButtonController;

@end

@implementation VInsetActionView

#pragma mark - VAbstractActionView

- (void)setReposting:(BOOL)reposting
{
    [super setReposting:reposting];
    
    self.repostButtonController.reposting = reposting;
}

#pragma mark - Property Accessors

- (UIButton *)shareButton
{
    if (_shareButton == nil)
    {
        _shareButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_shareIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                            action:@selector(share:)];
    }
    return _shareButton;
}

- (UIButton *)gifButton
{
    if (_gifButton == nil)
    {
        _gifButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_gifIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                          action:@selector(gif:)];
    }
    return _gifButton;
}

- (UIButton *)memeButton
{
    if (_memeButton == nil)
    {
        _memeButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_memeIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                           action:@selector(meme:)];
    }
    return _memeButton;
}

- (UIButton *)repostButton
{
    if (_repostButton == nil)
    {
        _repostButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_repostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                             action:@selector(repost:)];
    }
    return _repostButton;
}

#pragma mark - VUpdateHooks

- (void)updateActionItemsOnBar:(VActionBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    if (actionBar == nil)
    {
        return;
    }
    
    // Create an array of available action items
    NSMutableArray *justActionItems = [[NSMutableArray alloc] init];
    [justActionItems addObject:self.shareButton];
    if ( sequence.permissions.canRemix && [sequence isVideo])
    {
        [justActionItems addObject:self.gifButton];
    }
    if ( sequence.permissions.canRemix )
    {
        [justActionItems addObject:self.memeButton];
    }
    if ( sequence.permissions.canRemix )
    {
        [justActionItems addObject:self.repostButton];
    }
    
    // Calculate spacing
    __block CGFloat remainingSpace = CGRectGetWidth(actionBar.bounds);
    [justActionItems enumerateObjectsUsingBlock:^(UIButton *actionItem, NSUInteger idx, BOOL *stop)
    {
        remainingSpace = remainingSpace - [actionItem v_internalWidthConstraint].constant;
    }];
    CGFloat spacingWidth = remainingSpace / justActionItems.count;
    
    // Add our action items and spacing to an array to provide to the action bar
    // Edge spacing should be half the inter-item spacing
    NSMutableArray *actionItemsAndSpacing = [[NSMutableArray alloc] init];
    [actionItemsAndSpacing addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:spacingWidth * 0.5f]];
    [justActionItems enumerateObjectsUsingBlock:^(UIButton *actionButton, NSUInteger idx, BOOL *stop)
    {
        [actionItemsAndSpacing addObject:actionButton];
        if (actionButton != [justActionItems lastObject])
        {
            [actionItemsAndSpacing addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:spacingWidth]];
        }
    }];
    [actionItemsAndSpacing addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:spacingWidth * 0.5f]];
    
    actionBar.actionItems = [NSArray arrayWithArray:actionItemsAndSpacing];
}

- (void)updateRepostButtonForSequence:(VSequence *)sequence
{
    [self.repostButtonController invalidate];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:[UIImage imageNamed:@"C_repostIcon-success"]
                                                                    unRepostedImage:[UIImage imageNamed:@"C_repostIcon"]];
}

#pragma mark - Button Factory

- (UIButton *)actionButtonWithImage:(UIImage *)actionImage
                             action:(SEL)action
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [actionButton setImage:actionImage forState:UIControlStateNormal];
    actionButton.tintColor = [UIColor blackColor];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [actionButton v_addWidthConstraint:kActionButtonWidth];
    
    return actionButton;
}

@end
