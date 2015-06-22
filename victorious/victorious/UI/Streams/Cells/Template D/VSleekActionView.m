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
#import "VFlexBar.h"
#import "VActionBarFlexibleSpaceItem.h"
#import "VActionBarFixedWidthItem.h"
#import "VRoundedBackgroundButton.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VLargeNumberFormatter.h"
#import "VRepostButtonController.h"

static CGFloat const kLeadingTrailingSpace = 15.0f;
static CGFloat const kCommentSpaceToActions = 22.0f;
static CGFloat const kInterActionSpace = 23.0f;
static CGFloat const kCommentWidth = 68.0f;
static CGFloat const kActionButtonHeight = 31.0f;

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

// Each view will be reused for a unique configuration (share only, share+repost, et)
@property (nonatomic, assign) BOOL hasLayedOutActionView;

@end

@implementation VSleekActionView

#pragma mark - Reuse Identifiers

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
{
    NSMutableString *identifier = [baseIdentifier mutableCopy];

    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        if ( sequence.permissions.canComment )
        {
            [identifier appendString:@"Comment."];
        }
        [identifier appendString:@"Share."];
        if ( sequence.permissions.canRepost )
        {
            [identifier appendString:@"Repost."];
        }
        if ( sequence.permissions.canRemix )
        {
            [identifier appendString:@"Meme."];
        }
        if ( sequence.permissions.canRemix && [sequence isVideo])
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

- (VRoundedBackgroundButton *)commentButton
{
    if (_commentButton == nil)
    {
        _commentButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectZero];
        [_commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *commentIcon = [self.dependencyManager imageForKey:VCommentIconKey];
        [_commentButton setImage:[commentIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                        forState:UIControlStateNormal];
        [_commentButton v_addWidthConstraint:kCommentWidth];
        [_commentButton v_addHeightConstraint:kActionButtonHeight];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        _commentButton.unselectedColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        _commentButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
    }
    return _commentButton;
}

- (VRoundedBackgroundButton *)shareButton
{
    if (_shareButton == nil)
    {
        _shareButton = [self actionButtonWithImageKey:VShareIconKey action:@selector(share:)];
    }
    return _shareButton;
}

- (VRoundedBackgroundButton *)repostButton
{
    if (_repostButton == nil)
    {
        _repostButton = [self actionButtonWithImageKey:VRepostIconKey action:@selector(repost:)];
    }
    return _repostButton;
}

- (VRoundedBackgroundButton *)memeButton
{
    if (_memeButton == nil)
    {
        _memeButton = [self actionButtonWithImageKey:VMemeIconKey action:@selector(meme:)];
    }
    return _memeButton;
}

- (VRoundedBackgroundButton *)gifButton
{
    if (_gifButton == nil)
    {
        _gifButton = [self actionButtonWithImageKey:VGifIconKey action:@selector(gif:)];
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
        self.commentButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
        self.commentButton.titleLabel.font = [_dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        self.commentButton.unselectedColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        
        self.actionButtons = @[self.shareButton, self.repostButton, self.memeButton, self.gifButton];
        [self.actionButtons enumerateObjectsUsingBlock:^(VRoundedBackgroundButton *actionButton, NSUInteger idx, BOOL *stop)
         {
             actionButton.unselectedColor = [_dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
             actionButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
         }];
        
        //Update buttons for images from dependencyManager
        [self updateActionButton:self.commentButton toImageWithKey:VCommentIconKey];
        [self updateActionButton:self.shareButton toImageWithKey:VShareIconKey];
        [self updateActionButton:self.memeButton toImageWithKey:VMemeIconKey];
        [self updateActionButton:self.gifButton toImageWithKey:VGifIconKey];
        [self updateRepostButtonForSequence:self.sequence];
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
    
    if ( sequence.permissions.canComment )
    {
        [actionItems addObject:self.commentButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kCommentSpaceToActions]];
    }
    
    [actionItems addObject:self.shareButton];
    [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    if ( sequence.permissions.canRepost )
    {
        [actionItems addObject:self.repostButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    if ( sequence.permissions.canRemix )
    {
        [actionItems addObject:self.memeButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    if ( sequence.permissions.canRemix && [sequence isVideo])
    {
        [actionItems addObject:self.gifButton];
        [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    }
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    actionBar.actionItems = actionItems;
    
    self.hasLayedOutActionView = YES;
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
    UIImage *repostImage = [self.dependencyManager imageForKey:VRepostIconKey];
    UIImage *repostSuccessImage = [self.dependencyManager imageForKey:VRepostSuccessIconKey];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:repostSuccessImage
                                                                    unRepostedImage:repostImage];
}

#pragma mark - Button Factory

- (VRoundedBackgroundButton *)actionButtonWithImageKey:(NSString *)imageKey
                                                action:(SEL)action
{
    VRoundedBackgroundButton *actionButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectMake(0, 0, kActionButtonHeight, kActionButtonHeight)];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    actionButton.selected = NO;
    actionButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    actionButton.unselectedColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    actionButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [self updateActionButton:actionButton toImageWithKey:imageKey];
    [actionButton v_addWidthConstraint:kActionButtonHeight];
    [actionButton v_addHeightConstraint:kActionButtonHeight];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

- (void)updateActionButton:(UIButton *)actionButton toImageWithKey:(NSString *)imageKey
{
    UIImage *image = [self.dependencyManager imageForKey:imageKey];
    [actionButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

@end
