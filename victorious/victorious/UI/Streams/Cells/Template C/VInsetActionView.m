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

@interface VInsetActionView ()

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *gifButton;
@property (nonatomic, strong) UIButton *memeButton;
@property (nonatomic, strong) UIButton *repostButton;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VRepostButtonController *repostButtonController;

@end

@implementation VInsetActionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.shareButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_shareIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                            action:@selector(share:)];
    self.gifButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_gifIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                          action:@selector(gif:)];
    self.memeButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_memeIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                           action:@selector(meme:)];
    self.repostButton = [self actionButtonWithImage:[[UIImage imageNamed:@"C_repostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                                 action:@selector(repost:)];
}

#pragma mark - VAbstractActionView

- (void)setReposting:(BOOL)reposting
{
    [super setReposting:reposting];
    
    self.repostButtonController.reposting = reposting;
}

#pragma mark - VUpdateHooks

- (void)updateActionItemsOnBar:(VActionBar *)actionBar
                   forSequence:(VSequence *)sequence
{
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    [actionItems addObject:self.shareButton];
    [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    
    if ([sequence canRemix] && [sequence isVideo])
    {
        [actionItems addObject:self.gifButton];
        [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    }
    if ([sequence canRemix])
    {
        [actionItems addObject:self.memeButton];
        [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    }
    
    if ([sequence canRepost])
    {
        [actionItems addObject:self.repostButton];
        [actionItems addObject:[VActionBarFlexibleSpaceItem flexibleSpaceItem]];
    }
    
    actionBar.actionItems = actionItems;
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
    
    return actionButton;
}

@end
