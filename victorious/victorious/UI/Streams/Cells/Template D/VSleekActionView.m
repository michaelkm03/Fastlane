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

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VLargeNumberFormatter.h"
#import "VRepostButtonController.h"

static CGFloat const kLeadingTrailingSpace = 15.0f;
static CGFloat const kCommentSpaceToActions = 22.0f;
static CGFloat const kInterActionSpace = 23.0f;
static CGFloat const kActionButtonHeight = 31.0f;

@interface VSleekActionView ()

@property (nonatomic, strong) VRoundedBackgroundButton *commentButton;
@property (nonatomic, strong) VRoundedBackgroundButton *repostButton;
@property (nonatomic, strong) VRoundedBackgroundButton *memeButton;
@property (nonatomic, strong) VRoundedBackgroundButton *gifButton;
@property (nonatomic, strong, readwrite) VRoundedBackgroundButton *likeButton;
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
        _commentButton = [self actionButtonWithImage:[UIImage imageNamed:@"D_commentIcon"] action:@selector(comment:)];
    }
    return _commentButton;
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

- (VRoundedBackgroundButton *)likeButton
{
    if (_likeButton == nil)
    {
        UIImage *image = [UIImage imageNamed:@"D_like"];
        UIImage *activeImage = [UIImage imageNamed:@"D_liked"];
        _likeButton = [self actionButtonWithImage:image activeImage:activeImage action:@selector(like:)];
    }
    return _likeButton;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if (_dependencyManager != nil)
    {
        self.likeButton.activeTintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        
        self.actionButtons = @[ self.likeButton, self.repostButton, self.memeButton, self.gifButton, self.commentButton ];
        [self.actionButtons enumerateObjectsUsingBlock:^(VRoundedBackgroundButton *actionButton, NSUInteger idx, BOOL *stop)
         {
             actionButton.unselectedColor = [_dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
             actionButton.inactiveTintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
             actionButton.unselectedColor = [_dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
         }];
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
    
    [actionItems addObject:self.likeButton];
    [actionItems addObject:[VActionBarFixedWidthItem fixedWidthItemWithWidth:kInterActionSpace]];
    
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

- (void)updateRepostButtonForSequence:(VSequence *)sequence
{
    [self.repostButtonController invalidate];
    self.repostButtonController = [[VRepostButtonController alloc] initWithSequence:sequence
                                                                       repostButton:self.repostButton
                                                                      repostedImage:[UIImage imageNamed:@"D_repostIcon-success"]
                                                                    unRepostedImage:[UIImage imageNamed:@"D_repostIcon"]];
}

#pragma mark - Button Factory

- (VRoundedBackgroundButton *)actionButtonWithImage:(UIImage *)actionImage action:(SEL)action
{
    return [self actionButtonWithImage:actionImage activeImage:nil action:action];
}

- (VRoundedBackgroundButton *)actionButtonWithImage:(UIImage *)actionImage
                                        activeImage:(UIImage *)actionImageActive
                                             action:(SEL)action
{
    VRoundedBackgroundButton *actionButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectMake(0, 0, kActionButtonHeight, kActionButtonHeight)];
    actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    actionButton.selected = NO;
    actionButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    actionButton.unselectedColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    actionButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    actionButton.inactiveImage = [actionImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    actionButton.activeImage = [actionImageActive imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [actionButton v_addWidthConstraint:kActionButtonHeight];
    [actionButton v_addHeightConstraint:kActionButtonHeight];
    [actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return actionButton;
}

@end
