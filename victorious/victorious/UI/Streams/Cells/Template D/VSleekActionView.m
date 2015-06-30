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
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VLargeNumberFormatter.h"
#import "VRepostButtonController.h"

static CGFloat const kLeadingTrailingSpace = 15.0f;
static CGFloat const kCommentSpaceToActions = 22.0f;
static CGFloat const kInterActionSpace = 23.0f;
static CGFloat const kActionButtonHeight = 31.0f;

@interface VSleekActionView ()

@property (nonatomic, strong) VSleekActionButton *commentButton;
@property (nonatomic, strong) VSleekActionButton *repostButton;
@property (nonatomic, strong) VSleekActionButton *memeButton;
@property (nonatomic, strong) VSleekActionButton *gifButton;
@property (nonatomic, strong, readwrite) VSleekActionButton *likeButton;
@property (nonatomic, strong) NSArray *actionButtons;

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VRepostButtonController *repostButtonController;

// Each view will be reused for a unique configuration (share only, share+repost, et)
@property (nonatomic, assign) BOOL hasLayedOutActionView;

@end

@implementation VSleekActionView

#pragma mark - Reuse Identifiers

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier dependencyManager:(VDependencyManager *)dependencyManager
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
        if ( sequence.permissions.canGIF )
        {
            [identifier appendString:@"Gif."];
        }
    }
    else
    {
        NSString *errorString = [NSString stringWithFormat:@"This action view isn't prepared to handle streamItems of class %@", NSStringFromClass([streamItem class])];
        NSAssert(false, errorString);
    }
    
    return [NSString stringWithString:identifier];
}

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
        _repostButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_repostIcon"] action:@selector(repost:)];
    }
    return _repostButton;
}

- (VSleekActionButton *)memeButton
{
    if (_memeButton == nil)
    {
        _memeButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_memeIcon"] action:@selector(meme:)];
    }
    return _memeButton;
}

- (VSleekActionButton *)gifButton
{
    if (_gifButton == nil)
    {
        _gifButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_gifIcon"] action:@selector(gif:)];
    }
    return _gifButton;
}

- (VSleekActionButton *)likeButton
{
    if (_likeButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"D_like"];
        UIImage *selectedImage = [UIImage imageNamed:@"D_liked"];
        _likeButton = [self actionButtonWithImage:image selectedImage:selectedImage action:@selector(like:)];
    }
    return _likeButton;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if (_dependencyManager != nil)
    {
        self.actionButtons = @[ self.likeButton, self.repostButton, self.memeButton, self.gifButton, self.commentButton ];
        [self.actionButtons enumerateObjectsUsingBlock:^(VSleekActionButton *actionButton, NSUInteger idx, BOOL *stop)
         {
             actionButton.unselectedTintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
             actionButton.backgroundColor = [_dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
         }];
        
        self.likeButton.selectedTintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
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
    
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kLeadingTrailingSpace]];
    
    if ( [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
    {
        [actionItems addObject:self.likeButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kCommentSpaceToActions]];
    }
    if ( sequence.permissions.canComment )
    {
        [actionItems addObject:self.commentButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kCommentSpaceToActions]];
    }
    
    if ( sequence.permissions.canRepost )
    {
        [actionItems addObject:self.repostButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    if ( sequence.permissions.canMeme )
    {
        [actionItems addObject:self.memeButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    if ( sequence.permissions.canGIF )
    {
        [actionItems addObject:self.gifButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    actionBar.actionItems = actionItems;
    
    self.hasLayedOutActionView = YES;
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

- (VSleekActionButton *)actionButtonWithImage:(UIImage *)image action:(SEL)action
{
    return [self actionButtonWithImage:image selectedImage:nil action:action];
}

- (VSleekActionButton *)actionButtonWithImage:(UIImage *)image
                                      selectedImage:(UIImage *)selectedImage
                                             action:(SEL)action
{
    VSleekActionButton *actionButton = [[VSleekActionButton alloc] initWithFrame:CGRectMake(0, 0, kActionButtonHeight, kActionButtonHeight)];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    actionButton.unselectedTintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    actionButton.selectedTintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [actionButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [actionButton setImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    actionButton.selected = NO;
    [actionButton v_addWidthConstraint:kActionButtonHeight];
    [actionButton v_addHeightConstraint:kActionButtonHeight];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

@end
