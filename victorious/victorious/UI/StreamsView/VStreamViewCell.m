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

NSString* kStreamsWillSegueNotification = @"kStreamsWillSegueNotification";

@interface VStreamViewCell()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.text.username"];
}

- (void)layoutSubviews
{
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.clipsToBounds = YES;
}

- (void)setSequence:(VSequence *)sequence
{
    if(_sequence == sequence)
    {
        return;
    }

    _sequence = sequence;

    self.usernameLabel.text = self.sequence.user.name;
    self.locationLabel.text = self.sequence.user.location;
    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                             placeholderImage:[UIImage new]];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.sequence.user.pictureUrl]
                          placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
}

- (IBAction)likeButtonAction:(id)sender
{
    [[VObjectManager sharedManager]
     likeSequence:self.sequence
     successBlock:^(NSArray *resultObjects)
     {
         self.likeButton.userInteractionEnabled = NO;
         self.dislikeButton.userInteractionEnabled = YES;
     }
     failBlock:^(NSError *error)
     {
         VLog(@"Like failed with error: %@", error);
     }];
}

- (IBAction)commentButtonAction:(id)sender
{

}

- (IBAction)shareButtonAction:(id)sender
{
    
}


@end
