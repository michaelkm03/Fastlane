//
//  VImageSearchResultsFooterView.m
//  victorious
//
//  Created by Josh Hinman on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImageSearchResultsFooterView.h"
#import "VThemeManager.h"

@interface VImageSearchResultsFooterView ()

@property (nonatomic, weak) IBOutlet UILabel *pullUpForMoreLabel;
@property (nonatomic, weak) IBOutlet UIView  *refreshImageSuperview;

@end

@implementation VImageSearchResultsFooterView

- (void)awakeFromNib
{
    self.pullUpForMoreLabel.text = NSLocalizedString(@"Pull up for more...", @"");
    self.pullUpForMoreLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.refreshImageView.translatesAutoresizingMaskIntoConstraints = YES; // opt-out of autolayout for this view so we can scale it with a transform
}

- (void)setRefreshImageView:(UIImageView *)refreshImageView
{
    _refreshImageView = refreshImageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.refreshImageView.bounds = CGRectMake(0.0f, 0.0f, self.refreshImageView.intrinsicContentSize.width, self.refreshImageView.intrinsicContentSize.height);
    self.refreshImageView.center = CGPointMake(CGRectGetMidX(self.refreshImageSuperview.bounds), CGRectGetMidY(self.refreshImageSuperview.bounds));
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.refreshImageView.transform = CGAffineTransformIdentity;
    self.refreshImageView.hidden = NO;
    [self.activityIndicatorView stopAnimating];
}

@end
