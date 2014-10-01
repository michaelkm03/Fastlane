//
//  VTickerCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTickerCell.h"

// Subviews
#import "VProgressBarView.h"

// Theme
#import "VThemeManager.h"

@interface VTickerCell ()

@property (weak, nonatomic) IBOutlet UIView *realtimeCommentStrip;
@property (weak, nonatomic) IBOutlet VProgressBarView *progressBar;

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

#pragma mark - Property Acceossors

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.progressBar.progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.progressBar setProgress:progress
                         animated:YES];
}

#pragma mark - Public Methods

@end
