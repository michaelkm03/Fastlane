//
//  VMarqueeCollectionCell.m
//  victorious
//
//  Created by Will Long on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeCollectionCell.h"

#import "VUserProfileViewController.h"

#import "VFullscreenMarqueeTabIndicatorView.h"
#import "VFullscreenMarqueeStreamItemCell.h"

#import "VStreamCollectionViewDataSource.h"
#import "VFullscreenMarqueeController.h"

#import "VStreamItem.h"
#import "VUser.h"

#import "VThemeManager.h"
#import "VSettingManager.h"

#import "VTimerManager.h"

static CGFloat const kVTabSpacingRatio = 0.357;//From spec file, 25/640
static CGFloat const kVTabSpacingRatioC = 1.285;//From spec file, 25/640

@interface VFullscreenMarqueeCollectionCell() <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;
@property (nonatomic, strong) VFullscreenMarqueeTabIndicatorView *tabView;
@property (nonatomic, strong) VFullscreenMarqueeController *marquee;

@end

@implementation VFullscreenMarqueeCollectionCell

@dynamic marquee;

- (void)awakeFromNib
{
    [self.marqueeCollectionView registerNib:[VFullscreenMarqueeStreamItemCell nibForCell] forCellWithReuseIdentifier:[VFullscreenMarqueeStreamItemCell suggestedReuseIdentifier]];
    
    self.tabView = [[VFullscreenMarqueeTabIndicatorView alloc] initWithFrame:self.tabContainerView.bounds];
    self.tabView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tabContainerView addSubview:self.tabView];
    
    NSDictionary *tabView = @{ @"tabView":self.tabView };
    [self.tabContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:tabView]];
    [self.tabContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tabView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:tabView]];
}

- (void)setHideMarqueePosterImage:(BOOL)hideMarqueePosterImage
{
    _hideMarqueePosterImage = hideMarqueePosterImage;
    if ( !self.hideMarqueePosterImage )
    {
        self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.tabView.deselectedColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor] colorWithAlphaComponent:.3f];
        self.tabView.tabImage = [UIImage imageNamed:@"tabIndicator"];
        self.tabView.spacingBetweenTabs = self.tabView.tabImage.size.width * kVTabSpacingRatio;
        
        self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
        self.marqueeCollectionView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
    else
    {
        self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.tabView.deselectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.tabView.tabImage = [UIImage imageNamed:@"tabIndicatorDot"];
        self.tabView.spacingBetweenTabs = self.tabView.tabImage.size.width * kVTabSpacingRatioC;
        
        self.backgroundColor = [UIColor clearColor];
    }
    self.marquee.hideMarqueePosterImage = hideMarqueePosterImage;
}

- (void)setMarquee:(VFullscreenMarqueeController *)marquee
{
    marquee.tabView = self.tabView;
    self.tabView.numberOfTabs = marquee.streamDataSource.count;
    
    [super setMarquee:marquee];
    
    self.hideMarqueePosterImage = marquee.hideMarqueePosterImage;
}

- (void)updatedFromRefresh
{
    self.tabView.numberOfTabs = self.marquee.streamDataSource.count;
    self.tabView.currentlySelectedTab = self.marquee.currentPage;
}

#pragma mark - desiredCellSize

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VFullscreenMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

@end
