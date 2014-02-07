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

#import "VProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIButton+VImageLoading.h"

#import "VConstants.h"

#import "VCommentCell.h"

NSString *kStreamsWillShareNotification = @"kStreamsWillShareNotification";
NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";
@interface VStreamViewCell()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (nonatomic) NSUInteger originalHeight;

@property (strong, nonatomic) NSMutableArray* commentViews;

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
    
    self.originalHeight = self.frame.size.height;
    
    self.commentViews = [[NSMutableArray alloc] init];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamUsernameFont];
    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamLocationFont];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamDateFont];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamDescriptionFont];
    
}

- (void)layoutSubviews
{
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.clipsToBounds = YES;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    if ([[[_sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        self.playButtonImage.hidden = NO;
    else
        self.playButtonImage.hidden = YES;

    self.usernameLabel.text = self.sequence.user.name;
    self.locationLabel.text = self.sequence.user.location;
    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                          placeholderImage:[UIImage new]];
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.sequence.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    
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
    
//    [self addCommentViews];
}

- (void)addCommentViews
{
    NSInteger currentCommentCount = MIN([self.sequence.comments count], 2);
    NSInteger commentDiff = currentCommentCount - [self.commentViews count];
    
    //If we don't have any new or old comments bail out
    if (!currentCommentCount && ![self.commentViews count])
        return;
    
    //Change the height if we need to
    if (!currentCommentCount)
    {
        [self setHeight:self.originalHeight];
    }
    else if (commentDiff)
    {
        CGFloat height = self.frame.size.height;
        
        //no old comments so add header height
        if (![self.commentViews count])
            height += kStreamCommentHeaderHeight;
        
        //Add appropriate cell height and set it
        int scaler = commentDiff > 0 ? 1 : -1;
        height = height + ((abs(commentDiff) * kStreamCommentCellHeight) * scaler);
        [self setHeight:height];
    }

    //remove old views
    for (UIView* commentView in self.commentViews)
    {
        [commentView removeFromSuperview];
    }
    [self.commentViews removeAllObjects];
    
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
    NSArray* sortedComments = [[self.sequence.comments allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
    //add new views
    for (int i = 0; i < currentCommentCount; i++)
    {
        VCommentCell* cell = [[[NSBundle mainBundle] loadNibNamed:kCommentCellIdentifier
                                                            owner:self options:nil] objectAtIndex:0];
        cell.commentOrMessage = [sortedComments objectAtIndex:0];
        
        CGFloat yOffset = self.originalHeight + kStreamCommentHeaderHeight + (kStreamCommentCellHeight * i);
        cell.frame = CGRectMake(0, yOffset, self.frame.size.width, kStreamCommentCellHeight);
        [self addSubview:cell];
        [self.commentViews addObject:cell];
    }
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
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
    VProfileViewController* profileViewController = [VProfileViewController profileWithUserID:[self.sequence.createdBy integerValue]];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

@end
