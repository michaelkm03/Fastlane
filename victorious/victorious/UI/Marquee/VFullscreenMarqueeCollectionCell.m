//
//  VFullscreenMarqueeCollectionCell.m
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

#import "VSettingManager.h"

#import "VTimerManager.h"

#import "VStream.h"

#import "VAbstractMarqueeController.h"

static CGFloat const kVTabSpacingRatioC = 1.285;//From spec file, 25/640

@interface VFullscreenMarqueeCollectionCell() <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;
@property (nonatomic, strong) VFullscreenMarqueeTabIndicatorView *tabView;

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

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.tabView.selectedColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.tabView.deselectedColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey];
    self.tabView.tabImage = [UIImage imageNamed:@"tabIndicatorDot"];
    self.tabView.spacingBetweenTabs = self.tabView.tabImage.size.width * kVTabSpacingRatioC;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setMarquee:(VFullscreenMarqueeController *)marquee
{
    marquee.tabView = self.tabView;
    self.tabView.numberOfTabs = marquee.stream.marqueeItems.count;
    
    [super setMarquee:marquee];
}

- (void)marquee:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems
{
    self.tabView.numberOfTabs = streamItems.count;
    self.tabView.currentlySelectedTab = self.marquee.currentPage;
}

#pragma mark - desiredCellSize

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VFullscreenMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

@end
