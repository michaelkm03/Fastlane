//
//  VStreamViewCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamViewCell.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VUser.h"
#import "VRootNavigationController.h"

#import "VSequence+Fetcher.h"
#import "VAsset.h"

NSString* kStreamsWillSegueNotification = @"kStreamsWillSegueNotification";
NSString *kStreamsWillShareNotification = @"kStreamsWillShareNotification";
NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";
@interface VStreamViewCell()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@end

@implementation VStreamViewCell

// HACK: useing a cache for now to keep track of liked sequences
- (NSCache *)likeCache
{
    static NSCache *cache = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cache = [NSCache new];
    });
    return cache;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.text.username"];
}

- (void)layoutSubviews
{
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.clipsToBounds = YES;
}

- (void)setSequence:(VSequence *)sequence
{
    if(_sequence == sequence)
    {
        return;
    }
    _sequence = sequence;
    
    if ([[_sequence firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        self.playButtonImage.hidden = NO;
    else
        self.playButtonImage.hidden = YES;

    self.usernameLabel.text = self.sequence.user.name;
    self.locationLabel.text = self.sequence.user.location;
    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                             placeholderImage:[UIImage new]];
//    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.sequence.user.pictureUrl]
//                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];

    if([[self likeCache] objectForKey:self.sequence.remoteId])
    {
        [self.likeButton setImage:[[UIImage imageNamed:@"StreamHeartFull"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.likeButton setTitle:@" 124" forState:UIControlStateNormal];
    }
    else
    {
        [self.likeButton setImage:[UIImage imageNamed:@"StreamHeart"] forState:UIControlStateNormal];
        [self.likeButton setTitle:@" 123" forState:UIControlStateNormal];
    }
}

- (IBAction)likeButtonAction:(id)sender
{
//    [[VObjectManager sharedManager]
//     likeSequence:self.sequence
//     successBlock:^(NSArray *resultObjects)
//     {
//         self.likeButton.userInteractionEnabled = NO;
//         self.dislikeButton.userInteractionEnabled = YES;
//     }
//     failBlock:^(NSError *error)
//     {
//         VLog(@"Like failed with error: %@", error);
//     }];

    [[self likeCache] setObject:@YES forKey:self.sequence.remoteId];
    [self.likeButton setImage:[[UIImage imageNamed:@"StreamHeartFull"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.likeButton setTitle:@" 124" forState:UIControlStateNormal];
}

- (IBAction)commentButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStreamsWillCommentNotification object:self];
}

- (IBAction)shareButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStreamsWillShareNotification object:self.sequence];
}

- (IBAction)profileButtonAction:(id)sender
{
    VRootNavigationController *rootViewController =
    (VRootNavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController showUserProfileForUserID:self.sequence.createdBy.integerValue];
}

@end
