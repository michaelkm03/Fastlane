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
#import "VSequencePermissions.h"

// Action Bar
#import "VFlexBar.h"
#import "VActionBarFixedWidthItem.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VLargeNumberFormatter.h"

#import "victorious-Swift.h"

CGFloat const VActionButtonHeight = 31.0f;
static NSUInteger const kMaxNumberOfActionButtons = 4;

@interface VSleekActionView ()

@property (nonatomic, strong, readwrite) VSleekActionButton *commentButton;
@property (nonatomic, strong, readwrite) VSleekActionButton *repostButton;
@property (nonatomic, strong, readwrite) VSleekActionButton *likeButton;
@property (nonatomic, strong, readwrite) VSleekActionButton *moreButton;
@property (nonatomic, strong) NSArray *actionButtons;

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

// Each view will be reused for a unique configuration (share only, share+repost, et)
@property (nonatomic, assign) BOOL hasLayedOutActionView;

@end

@implementation VSleekActionView

#pragma mark - Reuse Identifiers

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableString *identifier = [baseIdentifier mutableCopy];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        if ( [dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
        {
            [identifier appendString:@"Like."];
        }
        if ( sequence.permissions.canComment )
        {
            [identifier appendString:@"Comment."];
        }
        if ( sequence.permissions.canRepost )
        {
            [identifier appendString:@"Repost."];
        }
        if ( sequence.permissions.canMeme )
        {
            [identifier appendString:@"Meme."];
        }
    }
    else
    {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *errorString = [NSString stringWithFormat:@"This action view isn't prepared to handle streamItems of class %@", NSStringFromClass([streamItem class])];
        NSAssert(false, errorString);
#endif
    }
    
    return [NSString stringWithString:identifier];
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

- (VSleekActionButton *)commentButton
{
    if (_commentButton == nil)
    {
        _commentButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_commentIcon"] action:@selector(comment:)];
    }
    return _commentButton;
}

- (VSleekActionButton *)repostButton
{
    if (_repostButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"D_repostIcon"];
        UIImage *selectedImage = [UIImage imageNamed:@"D_repostIcon-success"];
        _repostButton = [self actionButtonWithImage:image selectedImage:selectedImage action:@selector(repost:)];
    }
    return _repostButton;
}

- (VSleekActionButton *)likeButton
{
    if (_likeButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"D_likeIcon"];
        UIImage *selectedImage = [UIImage imageNamed:@"D_likedIcon"];
        _likeButton = [self actionButtonWithImage:image selectedImage:selectedImage action:@selector(like:)];
    }
    return _likeButton;
}

- (VSleekActionButton *)moreButton
{
    if (_moreButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"OverFlowIcon"];
        UIImage *selectedImage = [UIImage imageNamed:@"OverFlowIcon"];
        _moreButton = [self actionButtonWithImage:image selectedImage:selectedImage action:@selector(more:)];
    }
    return _moreButton;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if (_dependencyManager != nil)
    {
        self.actionButtons = @[ self.likeButton, self.repostButton, self.commentButton, self.moreButton ];
        [self.actionButtons enumerateObjectsUsingBlock:^(VSleekActionButton *actionButton, NSUInteger idx, BOOL *stop)
         {
             actionButton.unselectedTintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
             actionButton.selectedTintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
             actionButton.backgroundColor = [_dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
         }];
    }
}

+ (CGFloat)outerMarginForBarWidth:(CGFloat)width
{
    CGFloat summedButtonWidths = VActionButtonHeight * kMaxNumberOfActionButtons;
    CGFloat interButtonSpace = ( width - summedButtonWidths ) / kMaxNumberOfActionButtons;
    return interButtonSpace / 2;
}

#pragma mark - VUpdateHooks

- (void)updateActionItemsOnBar:(VFlexBar *)actionBar
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
    else
    {
        [self layoutIfNeeded];
    }
    
    CGFloat actionBarWidth = CGRectGetWidth(actionBar.bounds);
    if ( actionBarWidth == 0.0f )
    {
        //Nothing to do yet
        return;
    }
    
    NSMutableArray *actionButtons = [[NSMutableArray alloc] init];
    
    if ( [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
    {
        [actionButtons addObject:self.likeButton];
    }
    if ( sequence.permissions.canComment )
    {
        [actionButtons addObject:self.commentButton];
    }
    if ( sequence.permissions.canRepost )
    {
        [actionButtons addObject:self.repostButton];
    }
    [actionButtons addObject:self.moreButton];
    
    self.leftMargin = [[self class] outerMarginForBarWidth:actionBarWidth];
    CGFloat summedButtonWidths = VActionButtonHeight * kMaxNumberOfActionButtons;
    CGFloat interButtonSpace = ( actionBarWidth - summedButtonWidths ) / kMaxNumberOfActionButtons;
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    //The buttons should be inset from either edge of the cell by half the width of the space between each of them
    [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:interButtonSpace / 2]];
    for ( NSUInteger index = 0; index < MIN(actionButtons.count, kMaxNumberOfActionButtons - 1); index++ )
    {
        VSleekActionButton *actionButton = actionButtons[index];
        [actionItems addObject:actionButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:interButtonSpace]];
    }
    
    if ( actionButtons.count == kMaxNumberOfActionButtons )
    {
        [actionItems addObject:[actionButtons lastObject]];
    }
    
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    
    actionBar.actionItems = actionItems;
    
    self.hasLayedOutActionView = YES;
}

#pragma mark - Button Factory

- (VSleekActionButton *)actionButtonWithImage:(UIImage *)image action:(SEL)action
{
    return [self actionButtonWithImage:image selectedImage:nil action:action];
}

- (VSleekActionButton *)actionButtonWithImage:(UIImage *)image
                                      selectedImage:(UIImage *)selectedImage
                                             action:(SEL)action
{
    VSleekActionButton *actionButton = [[VSleekActionButton alloc] initWithFrame:CGRectMake(0, 0, VActionButtonHeight, VActionButtonHeight)];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    actionButton.unselectedTintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    actionButton.selectedTintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [actionButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [actionButton setImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    actionButton.selected = NO;
    [actionButton v_addWidthConstraint:VActionButtonHeight];
    [actionButton v_addHeightConstraint:VActionButtonHeight];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

@end
