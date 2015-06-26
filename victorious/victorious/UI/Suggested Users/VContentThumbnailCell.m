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
    self.imageView.image = image;
    if ( animated )
    {
        self.imageView.alpha = 0.0f;
        [UIView animateWithDuration:0.4f animations:^
         {
             self.imageView.alpha = 1.0f;
         }];
    }
}

@end
