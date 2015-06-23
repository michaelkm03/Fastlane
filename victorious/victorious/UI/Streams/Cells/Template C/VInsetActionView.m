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
#import "VFlexBar.h"
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
        _shareButton = [self actionButtonWithImageKey:VShareIconKey
                                               action:@selector(share:)];
    }
    return _shareButton;
}

- (UIButton *)gifButton
{
    if (_gifButton == nil)
    {
        _gifButton = [self actionButtonWithImageKey:VGifIconKey
                                             action:@selector(gif:)];
    }
    return _gifButton;
}

- (UIButton *)memeButton
{
    if (_memeButton == nil)
    {
        _memeButton = [self actionButtonWithImageKey:VMemeIconKey
                                              action:@selector(meme:)];
    }
    return _memeButton;
}

- (UIButton *)repostButton
{
    if (_repostButton == nil)
    {
        _repostButton = [self actionButtonWithImageKey:VRepostIconKey
                                                action:@selector(repost:)];
    }
    return _repostButton;
}

#pragma mark - VUpdateHooks

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier
{
    NSMutableString *identifier = [baseIdentifier mutableCopy];

    [identifier appendString:@"Share."];
    if ( sequence.permissions.canRepost )
    {
        [identifier appendString:@"Repost."];
    }
    if ( sequence.permissions.canMeme )
    {
        [identifier appendString:@"Meme."];
    }
    if ( sequence.permissions.canGIF )
    {
        [identifier appendString:@"Gif."];
    }
    
    return [NSString stringWithString:identifier];
}

- (void)updateActionItemsOnBar:(VFlexBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    if (actionBar == nil)
    {
        return;
    }
    
    // Create an array of available action items
    NSMutableArray *justActionItems = [[NSMutableArray alloc] init];
    [justActionItems addObject:self.shareButton];
    if ( sequence.permissions.canGIF )
    {
        [justActionItems addObject:self.gifButton];
    }
    if ( sequence.permissions.canMeme )
    {
        [justActionItems addObject:self.memeButton];
    }
    if ( sequence.permissions.canRepost )
    {
        [justActionItems addObject:self.repostButton];
    }
    
    // Calculate spacing
    __block CGFloat remainingSpace = CGRectGetWidth(actionBar.bounds);
    if (remainingSpace == 0.0f)
    {
        // Nothing to do here
        return;
    }
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
    for (UIView *actionView in actionBar.actionItems)
    {
        [actionBar v_addPinToTopBottomToSubview:actionView];
    }
}

- (void)updateRepostButtonForSequence:(VSequence *)sequence
{
    [self.repostButtonController invalidate];
    UIImage *repostImage = [self.dependencyManager imageForKey:VRepostIconKey];
    UIImage *repostSuccessImage = [self.dependencyManager imageForKey:VRepostSuccessIconKey];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:repostSuccessImage
                                                                    unRepostedImage:repostImage];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    UIColor *imageTintColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    self.shareButton.tintColor = imageTintColor;
    self.gifButton.tintColor = imageTintColor;
    self.memeButton.tintColor = imageTintColor;
    self.repostButton.tintColor = imageTintColor;
    
    //Update buttons for images from dependencyManager
    [self updateActionButton:self.shareButton toImageWithKey:VShareIconKey];
    [self updateActionButton:self.gifButton toImageWithKey:VGifIconKey];
    [self updateActionButton:self.memeButton toImageWithKey:VMemeIconKey];
    [self updateRepostButtonForSequence:self.sequence];
}

#pragma mark - Button Factory

- (UIButton *)actionButtonWithImageKey:(NSString *)imageKey
                                action:(SEL)action
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self updateActionButton:actionButton toImageWithKey:imageKey];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    actionButton.tintColor = [UIColor blackColor];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [actionButton v_addWidthConstraint:kActionButtonWidth];
    
    return actionButton;
}

- (void)updateActionButton:(UIButton *)actionButton toImageWithKey:(NSString *)imageKey
{
    UIImage *image = [self.dependencyManager imageForKey:imageKey];
    [actionButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

@end
