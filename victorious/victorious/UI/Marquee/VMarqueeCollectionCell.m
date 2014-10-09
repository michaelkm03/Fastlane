//
//  VMarqueeCollectionCell.m
//  victorious
//
//  Created by Will Long on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeCollectionCell.h"

#import "VUserProfileViewController.h"

#import "VMarqueeTabIndicatorView.h"
#import "VMarqueeStreamItemCell.h"

#import "VStreamCollectionViewDataSource.h"
#import "VMarqueeController.h"

#import "VStreamItem.h"
#import "VUser.h"

#import "VThemeManager.h"
#import "VSettingManager.h"

static CGFloat const kVTabSpacingRatio = 0.0390625;//From spec file, 25/640
static CGFloat const kVTabSpacingRatioC = 0.028125;//From spec file, 25/640
static const CGFloat kMarqueeBufferHeight = 3;

@interface VMarqueeCollectionCell()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *tabContainerView;
@property (nonatomic, strong) VMarqueeTabIndicatorView *tabView;

@end

@implementation VMarqueeCollectionCell

- (void)awakeFromNib
{
    [self.collectionView registerNib:[VMarqueeStreamItemCell nibForCell] forCellWithReuseIdentifier:[VMarqueeStreamItemCell suggestedReuseIdentifier]];
    
    self.tabView = [[VMarqueeTabIndicatorView alloc] initWithFrame:self.tabContainerView.frame];
    
    if (![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.tabView.deselectedColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor] colorWithAlphaComponent:.3f];
        self.tabView.spacingBetweenTabs = CGRectGetWidth(self.bounds) * kVTabSpacingRatio;
        self.tabView.tabImage = [UIImage imageNamed:@"tabIndicator"];
        
        self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
        self.collectionView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
    else
    {
        self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.tabView.deselectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.tabView.spacingBetweenTabs = CGRectGetWidth(self.bounds) * kVTabSpacingRatioC;
        self.tabView.tabImage = [UIImage imageNamed:@"tabIndicator"];
        
        self.backgroundColor = [UIColor colorWithWhite:0.94509803921 alpha:1];
//        self.collectionView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
    
    [self addSubview:self.tabView];
}

- (void)setMarquee:(VMarqueeController *)marquee
{
    _marquee = marquee;
    marquee.collectionView = self.collectionView;
    marquee.tabView = self.tabView;
    
    self.tabView.numberOfTabs = self.marquee.streamDataSource.count;
    
    [self.marquee.streamDataSource refreshWithSuccess:^(void)
     {
         self.tabView.numberOfTabs = self.marquee.streamDataSource.count;
         [self.marquee enableTimer];
         [self.collectionView reloadData];
     }
                                              failure:nil];
}

- (VStreamItem *)currentItem
{
    return self.marquee.currentStreamItem;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.marquee.autoScrollTimer invalidate];
}

- (void)restartAutoScroll
{
    [self.marquee enableTimer];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.marquee disableTimer];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self.marquee disableTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.marquee enableTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.marquee enableTimer];
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGSize size = [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
    size.height += kMarqueeBufferHeight;
    return size;
}

@end
