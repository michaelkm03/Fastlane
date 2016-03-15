//
//  VInsetActionView.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetActionView.h"

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

// Frameworks
@import KVOController;

static const CGFloat kActionButtonWidth = 44.0f;

@interface VInsetActionView ()

@property (nonatomic, strong, readwrite) VActionButton *memeButton;
@property (nonatomic, strong, readwrite) VActionButton *repostButton;
@property (nonatomic, strong, readwrite) VActionButton *commentButton;
@property (nonatomic, strong, readwrite) VActionButton *likeButton;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VInsetActionView

#pragma mark - Property Accessors

- (UIButton *)repostButton
{
    if (_repostButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_repost"];
        UIImage *selectedImage = [UIImage imageNamed:@"C_repostIcon-success"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _repostButton = [self actionButtonWithImage:image selectedImage:selectedImage backgroundImage:background action:@selector(repost:)];
    }
    return _repostButton;
}

- (UIButton *)likeButton
{
    if (_likeButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"C_like"];
        UIImage *selectedImage = [UIImage imageNamed:@"C_liked"];
        UIImage *background = [UIImage imageNamed:@"C_background"];
        _likeButton = [self actionButtonWithImage:image selectedImage:selectedImage backgroundImage:background action:@selector(like:)];
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

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    UIColor *unselectedTintColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    UIColor *selectedTintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    self.memeButton.unselectedTintColor = unselectedTintColor;
    self.repostButton.unselectedTintColor = unselectedTintColor;
    self.likeButton.unselectedTintColor = unselectedTintColor;
    self.commentButton.unselectedTintColor = unselectedTintColor;
    
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
