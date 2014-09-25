//
//  VMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeStreamItemCell.h"

#import "VStreamItem+Fetcher.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VThemeManager.h"

@interface VMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic) CGRect originalNameLabelFrame;

@end

@implementation VMarqueeStreamItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    self.nameLabel.text = streamItem.name;
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:[UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
    self.nameLabel.frame = self.originalNameLabelFrame;
}

@end
