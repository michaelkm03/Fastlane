//
//  VSleekActionView.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekActionView.h"

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

static CGFloat const kLeadingTrailingSpace = 15.0f;
static CGFloat const kCommentSpaceToActions = 22.0f;
static CGFloat const kInterActionSpace = 25.0f;
static CGFloat const kCommentWidth = 68.0f;
static CGFloat const kActionButtonHeight = 31.0f;
static CGFloat const kActionBackgroundColorConstant = 238.0f / 255.0f;

@interface VSleekActionView ()

@property (nonatomic, strong) VRoundedBackgroundButton *commentButton;
@property (nonatomic, strong) VRoundedBackgroundButton *shareButton;
@property (nonatomic, strong) VRoundedBackgroundButton *repostButton;
@property (nonatomic, strong) VRoundedBackgroundButton *memeButton;
@property (nonatomic, strong) VRoundedBackgroundButton *gifButton;
@property (nonatomic, strong) NSArray *actionButtons;

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VRepostButtonController *repostButtonController;

@end

@implementation VSleekActionView

#pragma mark - VAbstractActionView

- (void)setReposting:(BOOL)reposting
{
    [super setReposting:reposting];
    
    self.repostButtonController.reposting = reposting;
}

#pragma mark - Property Accessors

- (VLargeNumberFormatter *)largeNumberFormatter
{
    if (_largeNumberFormatter == nil)
    {
        _largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    
    return _largeNumberFormatter;
}

- (VRoundedBackgroundButton *)commentButton
{
    if (_commentButton == nil)
    {
        _commentButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectZero];
        [_commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
        [_commentButton setImage:[UIImage imageNamed:@"D_commentIcon"] forState:UIControlStateNormal];
        [_commentButton v_addWidthConstraint:kCommentWidth];
        [_commentButton v_addHeightConstraint:kActionButtonHeight];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        _commentButton.unselectedColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
    return _commentButton;
}

- (VRoundedBackgroundButton *)shareButton
{
    if (_shareButton == nil)
    {
        _shareButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_shareIcon"] action:@selector(share:)];
    }
    return _shareButton;
}

- (VRoundedBackgroundButton *)repostButton
{
    if (_repostButton == nil)
    {
        _repostButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_repostIcon"] action:@selector(repost:)];
    }
    return _repostButton;
}

- (VRoundedBackgroundButton *)memeButton
{
    if (_memeButton == nil)
    {
        _memeButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_memeIcon"] action:@selector(meme:)];
    }
    return _memeButton;
}

- (VRoundedBackgroundButton *)gifButton
{
    if (_gifButton == nil)
    {
        _gifButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_gifIcon"] action:@selector(gif:)];
    }
    return _gifButton;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if (_dependencyManager != nil)
    {
        //Override the default tint color to always have white text in the comment label
        [self.commentButton setTintColor:[UIColor whiteColor]];
        [[self.commentButton titleLabel] setFont:[_dependencyManager fontForKey:VDependencyManagerParagraphFontKey]];
        self.commentButton.unselectedColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        
        self.actionButtons = @[self.shareButton, self.repostButton, self.memeButton, self.gifButton];
        [self.actionButtons enumerateObjectsUsingBlock:^(VRoundedBackgroundButton *actionButton, NSUInteger idx, BOOL *stop)
         {
             actionButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
         }];
    }
}

#pragma mark - VUpdateHooks

- (void)updateActionItemsOnBar:(VActionBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    if (actionBar == nil)
    {
        return;
    }
    
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingSpace]];
    
    if ([sequence canComment])
    {
        [actionItems addObject:self.commentButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kCommentSpaceToActions]];
    }
    
    [actionItems addObject:self.shareButton];
    [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    if ([sequence canRepost])
    {
        [actionItems addObject:self.repostButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    if ([sequence canRemix])
    {
        [actionItems addObject:self.memeButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    if ([sequence canRemix] && [sequence isVideo])
    {
        [actionItems addObject:self.gifButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    actionBar.actionItems = actionItems;
}

- (void)updateCommentCountForSequence:(VSequence *)sequence
{
    if ([[sequence commentCount] integerValue] == 0)
    {
        [self.commentButton setTitle:@""
                            forState:UIControlStateNormal];
    }
    else
    {
        [self.commentButton setTitle:[self.largeNumberFormatter stringForInteger:[[sequence commentCount] integerValue]]
                            forState:UIControlStateNormal];
    }
}

- (void)updateRepostButtonForSequence:(VSequence *)sequence
{
    [self.repostButtonController invalidate];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:[UIImage imageNamed:@"D_repostIcon-success"]
                                                                    unRepostedImage:[UIImage imageNamed:@"D_repostIcon"]];
}

#pragma mark - Button Factory

- (VRoundedBackgroundButton *)actionButtonWithImage:(UIImage *)actionImage
                                             action:(SEL)action
{
    VRoundedBackgroundButton *actionButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectMake(0, 0, kActionButtonHeight, kActionButtonHeight)];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat colorVal = kActionBackgroundColorConstant;
    actionButton.unselectedColor = [UIColor colorWithRed:colorVal green:colorVal blue:colorVal alpha:1.0f];
    actionButton.selected = NO;
    actionButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [actionButton setImage:[actionImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                  forState:UIControlStateNormal];
    [actionButton v_addWidthConstraint:kActionButtonHeight];
    [actionButton v_addHeightConstraint:kActionButtonHeight];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

@end
