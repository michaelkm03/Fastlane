//
//  VSuggestedUserCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUserCell.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VFollowControl.h"
#import "UIView+AutoLayout.h"
#import "UIResponder+VResponderChain.h"
#import "VContentThumbnailsViewController.h"
#import "VContentThumbnailsDataSource.h"
#import "VSequence.h"
#import "victorious-Swift.h"

static NSString * const kTextTitleColorKey = @"color.text.label1";

@interface VSuggestedUserCell ()

@property (nonatomic, strong) VUser *user;
@property (nonatomic, strong) NSArray *recentSequences;
@property (nonatomic, strong) VFollowControl *followControl;
@property (nonatomic, strong) VContentThumbnailsDataSource *thumbnailsDataSource;
@property (nonatomic, strong) VContentThumbnailsViewController *thumbnailsViewController;
@property (nonatomic, weak) IBOutlet UIImageView *userProfileImage;
@property (nonatomic, weak) IBOutlet UITextView *usernameTextView;
@property (nonatomic, weak) IBOutlet UIView *followControlContainerView;
@property (nonatomic, weak) IBOutlet UIView *userStreamContainerView;

@end

@implementation VSuggestedUserCell

+ (NSMutableDictionary *)dataSources
{
    static NSMutableDictionary *_dataSources = nil;
    if ( _dataSources == nil )
    {
        _dataSources = [[NSMutableDictionary alloc] init];
    }
    return _dataSources;
}

- (void)awakeFromNib
{
    self.followControl = [[VFollowControl alloc] initWithFrame:self.followControlContainerView.bounds];
    [self.followControlContainerView addSubview:self.followControl];
    [self.followControlContainerView v_addFitToParentConstraintsToSubview:self.followControl];
    [self.followControl addTarget:self action:@selector(followControlPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.thumbnailsViewController = [[VContentThumbnailsViewController alloc] init];
    [self.userStreamContainerView addSubview:self.thumbnailsViewController.view];
    [self.userStreamContainerView v_addFitToParentConstraintsToSubview:self.thumbnailsViewController.view];
    self.userStreamContainerView.backgroundColor = [UIColor clearColor];
    
    self.thumbnailsDataSource = [[VContentThumbnailsDataSource alloc] initWithCollectionView:self.thumbnailsViewController.collectionView];
    self.thumbnailsViewController.collectionView.dataSource = self.thumbnailsDataSource;
    [self.thumbnailsDataSource registerCellsWithCollectionView:self.thumbnailsViewController.collectionView];
}

- (void)prepareForReuse
{
    self.thumbnailsDataSource.sequences = @[];
    [self.thumbnailsViewController.collectionView reloadData];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.followControl.dependencyManager = dependencyManager;
    [self applyStyle];
    self.thumbnailsDataSource.dependencyManager = dependencyManager;
}

- (void)configureWithSuggestedUser:(VSuggestedUser *)suggestedUser
{
    self.user = suggestedUser.user;
    self.usernameTextView.text = self.user.displayName;
    self.recentSequences = suggestedUser.recentSequences;
    self.thumbnailsDataSource.sequences = self.recentSequences;
    [self.thumbnailsViewController.collectionView reloadData];
    
    [self updateFollowingStateAnimated:NO];
}

- (void)applyStyle
{
    self.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.usernameTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.usernameTextView.textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self forKey:@"background.detail"];
}

- (void)updateFollowingStateAnimated:(BOOL)animated
{
    VFollowControlState controlState = [VFollowControl controlStateForFollowing:self.user.isFollowedByMainUser.boolValue];
    [self.followControl setControlState:controlState animated:animated];
}

- (IBAction)followControlPressed:(VFollowControl *)sender
{
    // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self;
}

@end
