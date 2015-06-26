//
//  VContentThumbnailCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentThumbnailCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "UIImageView+VLoadingAnimations.h"

@interface VContentThumbnailCell()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation VContentThumbnailCell

- (void)prepareForReuse
{
    self.imageView.image = nil;
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    if ( animated )
    {
        [self.imageView fadeInImage:image];
    }
    else
    {
        self.imageView.image = image;
    }
}

@end
