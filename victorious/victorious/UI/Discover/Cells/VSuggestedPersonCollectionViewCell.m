//
//  VSuggestedPersonCollectionViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPersonCollectionViewCell.h"

@interface VSuggestedPersonCollectionViewCell()

@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end

@implementation VSuggestedPersonCollectionViewCell

+ (UIImage *)followedImage
{
    static UIImage *followedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      followedImage = [UIImage imageNamed:@"followedIcon"];
                  });
    return followedImage;
}

+ (UIImage *)followImage
{
    static UIImage *followImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      followImage = [UIImage imageNamed:@"followedIcon"];
                  });
    return followImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat radius = self.profileImageView.bounds.size.width * 0.5f;
    self.profileImageView.layer.cornerRadius = radius;
}

- (void)setIsFollowed:(BOOL)isFollowed
{
    _isFollowed = isFollowed;
    
    if ( self.isFollowed )
    {
        [self.followButton setImage:[VSuggestedPersonCollectionViewCell followedImage] forState:UIControlStateNormal];
    }
    else
    {
        [self.followButton setImage:[VSuggestedPersonCollectionViewCell followImage] forState:UIControlStateNormal];
    }
}

- (IBAction)onFollow:(id)sender
{
    if ( self.isFollowed )
    {
        //[self.delegate unfollowUser:user];
    }
    else
    {
        //[self.delegate followUser:user];
    }
}

@end
