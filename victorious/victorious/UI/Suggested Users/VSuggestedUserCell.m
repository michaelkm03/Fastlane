//
//  VSuggestedUserCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUserCell.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VFollowUserControl.h"
#import "VFollowResponder.h"
#import "VUser.h"
#import "UIView+AutoLayout.h"
#import "UIResponder+VResponderChain.h"
#import "VDefaultProfileImageView.h"
#import "VContentThumbnailsViewController.h"
#import "VContentThumbnailsDataSource.h"
#import "VSequence.h"

static NSString * const kTextTitleColorKey = @"color.text.label1";
static NSString * const kTextBodyColorKey = @"color.text.label2";

@interface VSuggestedUserCell ()

@property (nonatomic, strong) VFollowUserControl *followButton;
@property (nonatomic, strong) VContentThumbnailsViewController *thumbnailsViewController;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *userProfileImage;
@property (nonatomic, weak) IBOutlet UITextView *usernameTextView;
@property (nonatomic, weak) IBOutlet UITextView *userTagLineTextView;
@property (nonatomic, weak) IBOutlet UIView *followButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *userStreamContainerView;

@property (nonatomic, strong) VUser *user;

@end

@implementation VSuggestedUserCell

+ (NSCache *)dataSourcesCache
{
    static NSCache *_dataSourcesCache = nil;
    if ( !_dataSourcesCache )
    {
        _dataSourcesCache = [[NSCache alloc] init];
    }
    return _dataSourcesCache;
}

- (void)awakeFromNib
{
    self.followButton = [[VFollowUserControl alloc] initWithFrame:self.followButtonContainerView.bounds];
    [self.followButtonContainerView addSubview:self.followButton];
    [self.followButtonContainerView v_addFitToParentConstraintsToSubview:self.followButton];
    [self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.thumbnailsViewController = [[VContentThumbnailsViewController alloc] init];
    [self.userStreamContainerView addSubview:self.thumbnailsViewController.view];
    [self.userStreamContainerView v_addFitToParentConstraintsToSubview:self.thumbnailsViewController.view];
    self.userStreamContainerView.backgroundColor = [UIColor clearColor];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.followButton.dependencyManager = dependencyManager;
    [self applyStyle];
}

- (void)setUser:(VUser *)user
{
    _user = user;
    
    self.usernameTextView.text = _user.name;
    self.userTagLineTextView.text = _user.tagline;
    
    VContentThumbnailsDataSource *thumbnailsDataSource = [[[self class] dataSourcesCache] objectForKey:user.remoteId];
    if ( thumbnailsDataSource == nil )
    {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VSequence *sequence, NSDictionary *bindings)
                                  {
                                      NSURL *url = [NSURL URLWithString:sequence.previewData];
                                      return url != nil && url.absoluteString.length > 0;
                                  }];
        NSArray *recentSequences = [user.recentSequences.array filteredArrayUsingPredicate:predicate];
        thumbnailsDataSource = [[VContentThumbnailsDataSource alloc] initWithSequences:recentSequences];
        self.thumbnailsViewController.collectionView.dataSource = thumbnailsDataSource;
        [thumbnailsDataSource registerCellsWithCollectionView:self.thumbnailsViewController.collectionView];
        
        [[[self class] dataSourcesCache] setObject:thumbnailsDataSource forKey:user.remoteId];
    }
    
    if ( _user.pictureUrl != nil )
    {
        [self.userProfileImage setProfileImageURL:[NSURL URLWithString:_user.pictureUrl]];
    }
    
    self.followButton.following = self.user.isFollowedByMainUser.boolValue;
}

- (void)applyStyle
{
    self.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.usernameTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.usernameTextView.textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
    
    self.userTagLineTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    self.userTagLineTextView.textColor = [self.dependencyManager colorForKey:kTextBodyColorKey];
    
    self.usernameTextView.textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
    self.userTagLineTextView.textColor = [self.dependencyManager colorForKey:kTextBodyColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self forKey:@"background.detail"];
}

- (IBAction)followButtonPressed:(VFollowUserControl *)sender
{
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withCompletion:)
                                                                      withSender:nil];
    
    NSAssert(followResponder != nil, @"Need a VFollowingResponder higher up the chain to communicate following commands.");
    sender.enabled = NO;
    
    if ( self.user.isFollowedByMainUser.boolValue )
    {
        [followResponder unfollowUser:self.user withCompletion:^(VUser *userActedOn)
         {
             [sender setFollowing:self.user.isFollowedByMainUser.boolValue animated:YES];
             sender.enabled = YES;
         }];
    }
    else
    {
        [followResponder followUser:self.user withCompletion:^(VUser *userActedOn)
         {
             [sender setFollowing:self.user.isFollowedByMainUser.boolValue animated:YES];
             sender.enabled = YES;
         }];
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self;
}

@end
