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

@property (nonatomic, strong) VActionButton *gifButton;
@property (nonatomic, strong) VActionButton *memeButton;
@property (nonatomic, strong) VActionButton *repostButton;
@property (nonatomic, strong) VActionButton *commentButton;
@property (nonatomic, strong, readwrite) VActionButton *likeButton;

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

- (UIButton *)gifButton
{
    if (_gifButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_gif"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _gifButton = [self actionButtonWithImage:image selectedImage:nil backgroundImage:background action:@selector(gif:)];
    }
    return _gifButton;
}

- (UIButton *)memeButton
{
    if (_memeButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_meme"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _memeButton = [self actionButtonWithImage:image selectedImage:nil backgroundImage:background action:@selector(meme:)];
    }
    return _memeButton;
}

- (UIButton *)repostButton
{
    if (_repostButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_repost"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _repostButton = [self actionButtonWithImage:image selectedImage:nil backgroundImage:background action:@selector(repost:)];
    }
    return _repostButton;
}

- (UIButton *)likeButton
{
    if (_likeButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_like"];
        UIImage *active = [UIImage imageNamed:@"C_liked"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _likeButton = [self actionButtonWithImage:image selectedImage:active backgroundImage:background action:@selector(like:)];
    }
    return _likeButton;
}

- (UIButton *)commentButton
{
    if (_commentButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_comment"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _commentButton = [self actionButtonWithImage:image selectedImage:nil backgroundImage:background action:@selector(comment:)];
    }
    return _commentButton;
}

#pragma mark - VUpdateHooks

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier
                       dependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableString *identifier = [baseIdentifier mutableCopy];
    
    if ( [dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
    {
        [identifier appendString:@"Like."];
    }
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
    if ( sequence.permissions.canComment )
    {
        [identifier appendString:@"Comment."];
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
    
    if ( [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
    {
        [justActionItems addObject:self.likeButton];
    }
    if ( sequence.permissions.canComment )
    {
        [justActionItems addObject:self.commentButton];
    }
    if ( sequence.permissions.canRepost )
    {
        [justActionItems addObject:self.repostButton];
    }
    if ( sequence.permissions.canGIF )
    {
        [justActionItems addObject:self.gifButton];
    }
    //Only add meme for image content
    if ( sequence.permissions.canMeme && sequence.isImage )
    {
        [justActionItems addObject:self.memeButton];
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
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:[UIImage imageNamed:@"C_reposted"]
                                                                    unRepostedImage:[UIImage imageNamed:@"C_repost"]];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    UIColor *unselectedTintColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    UIColor *selectedTintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    self.gifButton.unselectedTintColor = unselectedTintColor;
    self.memeButton.unselectedTintColor = unselectedTintColor;
    self.repostButton.unselectedTintColor = unselectedTintColor;
    self.likeButton.unselectedTintColor = unselectedTintColor;
    self.commentButton.unselectedTintColor = unselectedTintColor;
    
    self.gifButton.selectedTintColor = selectedTintColor;
    self.memeButton.selectedTintColor = selectedTintColor;
    self.repostButton.selectedTintColor = selectedTintColor;
    self.likeButton.selectedTintColor = selectedTintColor;
    self.commentButton.selectedTintColor = selectedTintColor;
}

#pragma mark - Button Factory

- (VActionButton *)actionButtonWithImage:(UIImage *)actionImage
                           selectedImage:(UIImage *)actionImageSelected
                         backgroundImage:(UIImage *)backgroundImage
                                  action:(SEL)action
{
    VActionButton *actionButton = [VActionButton actionButtonWithImage:[actionImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] selectedImage:[actionImageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] backgroundImage:[backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [actionButton v_addWidthConstraint:kActionButtonWidth];
    
    return actionButton;
}

@end
