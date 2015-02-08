//
//  VContentImageCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentImageCell.h"

@interface VContentImageCell ()

@end

@implementation VContentImageCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.shrinkingContentView = self.contentImageView;
}

@end
