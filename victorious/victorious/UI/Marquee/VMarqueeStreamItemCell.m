//
//  VMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeStreamItemCell.h"

#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import "VUser.h"

#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VThemeManager.h"

@interface VMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic) CGRect originalNameLabelFrame;

@end

static CGFloat const kVCellHeightRatio = 0.884375; //from spec, 283 height for 360 width

@implementation VMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.originalNameLabelFrame = self.nameLabel.frame;

//    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5f;
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor].CGColor;
    self.profileImageView.layer.borderWidth = 4;
    
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    self.nameLabel.text = streamItem.name;
    [self.nameLabel sizeToFit];
    
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:[UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    if ([streamItem isKindOfClass:[VSequence class]])
    {
        [self.profileImageView fadeInImageAtURL:[NSURL URLWithString:((VSequence *)streamItem).user.profileImagePathSmall]
                               placeholderImage:self.profileImageView.image];
        self.profileImageView.hidden = NO;
    }
    else
    {
        self.profileImageView.hidden = YES;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
    self.nameLabel.frame = self.originalNameLabelFrame;
    
    self.profileImageView.image = [UIImage imageNamed:@"profile_full"];
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = width * kVCellHeightRatio;
    return CGSizeMake(width, height);
}

@end
