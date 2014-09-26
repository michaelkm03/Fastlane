//
//  VMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeStreamItemCell.h"

#import "VStreamItem+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"

#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "UIButton+VImageLoading.h"

#import "VThemeManager.h"

@interface VMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *pollOrImageView;

@property (nonatomic, weak) IBOutlet UIButton *profileImageButton;

@property (nonatomic) CGRect originalNameLabelFrame;

@end

static CGFloat const kVCellHeightRatio = 0.884375; //from spec, 283 height for 360 width

@implementation VMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.originalNameLabelFrame = self.nameLabel.frame;
    
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor].CGColor;
    self.profileImageButton.layer.borderWidth = 4;
    self.profileImageButton.clipsToBounds = YES;
    self.profileImageButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];

    
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    self.nameLabel.text = streamItem.name;
    [self.nameLabel sizeToFit];
    
    if ([streamItem isKindOfClass:[VSequence class]] && [(VSequence*)streamItem isPoll])
    {
        self.pollOrImageView.hidden = NO;
    }
    else
    {
        self.pollOrImageView.hidden = YES;
    }
    
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:[UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    if ([streamItem isKindOfClass:[VSequence class]])
    {
        NSString *profileImagePath = ((VSequence *)streamItem).user.profileImagePathSmall ?: ((VSequence *)streamItem).user.pictureUrl;
        [self.profileImageButton setImageWithURL:[NSURL URLWithString:profileImagePath]
                                placeholderImage:[UIImage imageNamed:@"profile_full"]
                                        forState:UIControlStateNormal];
        self.profileImageButton.hidden = NO;
    }
    else
    {
        self.profileImageButton.hidden = YES;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
    self.nameLabel.frame = self.originalNameLabelFrame;
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
