//
//  VHistogramCell.m
//  victorious
//
//  Created by Michael Sena on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHistogramCell.h"

static const CGFloat kHistogramDesiredHeight = 19.0f;

@interface VHistogramCell ()

@property (nonatomic, weak, readwrite) IBOutlet VHistogramView *histogramView;

@end

@implementation VHistogramCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kHistogramDesiredHeight);
}

@end
