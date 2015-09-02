//
//  VNoContentCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNoContentCollectionViewCell.h"
#import "VDependencyManager.h"
#import "UIView+AutoLayout.h"

static const CGFloat kErrorCellHeight = 100;

@implementation VNoContentCollectionViewCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kErrorCellHeight);
}

@end
