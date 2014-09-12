//
//  VContentCaptionCell.m
//  victorious
//
//  Created by Michael Sena on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCaptionCell.h"

@implementation VContentCaptionCell

+ (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 70.0f);
}

@end
