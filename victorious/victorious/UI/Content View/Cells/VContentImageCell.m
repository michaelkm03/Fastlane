//
//  VContentImageCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentImageCell.h"

@interface VContentImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end

@implementation VContentImageCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - Property Accessors

- (void)setContentImage:(UIImage *)contentImage
{
    _contentImage = contentImage;
    self.contentImageView.image = contentImage;
}

@end
