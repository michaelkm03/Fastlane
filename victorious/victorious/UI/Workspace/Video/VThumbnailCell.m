//
//  VThumbnailCell.m
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VThumbnailCell.h"

@interface VThumbnailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation VThumbnailCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.activityIndicator startAnimating];
}

- (void)setThumbnail:(UIImage *)thumbnail
{
    self.thumbnailImageView.image = thumbnail;
    if (thumbnail)
    {
        [self.activityIndicator stopAnimating];
    }
}

- (UIImage *)thumbnail
{
    return self.thumbnailImageView.image;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.thumbnailImageView.image = nil;
    [self.activityIndicator startAnimating];
}

@end
