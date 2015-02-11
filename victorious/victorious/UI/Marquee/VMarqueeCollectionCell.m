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

static CGFloat const kVTabSpacingRatio = 0.357;//From spec file, 25/640
static CGFloat const kVTabSpacingRatioC = 1.285;//From spec file, 25/640
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
    [self.tabView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    
    if (![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.tabView.deselectedColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor] colorWithAlphaComponent:.3f];
        self.tabView.tabImage = [UIImage imageNamed:@"tabIndicator"];
        self.tabView.spacingBetweenTabs = self.tabView.tabImage.size.width * kVTabSpacingRatio;
        
        self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
        self.collectionView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
    else
    {
        self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.tabView.deselectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        self.tabView.tabImage = [UIImage imageNamed:@"tabIndicatorDot"];
        self.tabView.spacingBetweenTabs = self.tabView.tabImage.size.width * kVTabSpacingRatioC;

        self.backgroundColor = [UIColor clearColor];
    }
    
    [self addSubview:self.tabView];
    
    //Add constraints to tabView so it stays centered in it's superview
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tabView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.tabView.superview
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tabView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.tabView.superview
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];

}

- (void)setMarquee:(VMarqueeController *)marquee
{
    _marquee = marquee;
    marquee.collectionView = self.collectionView;
    marquee.tabView = self.tabView;
    
    self.tabView.numberOfTabs = self.marquee.streamDataSource.count;
    
    [self.marquee refreshWithSuccess:^(void)
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

- (UIImageView *)currentPreviewImageView
{
    NSIndexPath *path = [self.marquee.streamDataSource indexPathForItem:[self currentItem]];
    VMarqueeStreamItemCell *cell = (VMarqueeStreamItemCell *)[self.collectionView cellForItemAtIndexPath:path];
    return cell.previewImageView;
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
