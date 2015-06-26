//
//  VContentThumbnailCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentThumbnailCell.h"
#import "UIImageView+WebCache.h"

@interface VContentThumbnailCell()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation VContentThumbnailCell

- (void)setImageURL:(NSURL *)imageURL
{
    [self.imageView sd_setImageWithURL:imageURL];
}

@end
