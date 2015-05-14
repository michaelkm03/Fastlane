//
//  VTickerCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTickerCell.h"

@interface VTickerCell ()

@property (weak, nonatomic) IBOutlet UIView *realtimeCommentStrip;

@end

@implementation VTickerCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 92.0f);
}

+ (CGSize)desiredSizeForNoRealTimeCommentsWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 5.0f);
}

@end
