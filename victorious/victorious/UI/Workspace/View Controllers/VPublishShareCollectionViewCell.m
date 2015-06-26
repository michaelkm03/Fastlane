//
//  VPublishShareCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPublishShareCollectionViewCell.h"
#import "VDependencyManager+VShareMenuItem.h"
#import "VShareItemCollectionViewCell.h"
#import "VShareMenuItem.h"

static CGFloat const kPreferredRowHeight = 31.0f;
static CGFloat const kInterItemSpace = 5.0f;
static NSUInteger const kNumberOfColumns = 2;
static UIEdgeInsets const kDefaultContentInsets = { 4, 10, 12, 10 };
static CGFloat const kShareLabelHeight = 31.0f;
static NSString * const kShareTextKey = @"shareText";
static NSString * const kOptionsContainerBackgroundKey = @"color.optionsContainer";

@interface VPublishShareCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UILabel *shareLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *shareMenuItems;

@end

@implementation VPublishShareCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[VShareItemCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VShareItemCollectionViewCell suggestedReuseIdentifier]];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.contentInset = kDefaultContentInsets;
}

+ (CGFloat)desiredHeightForDependencyManager:(VDependencyManager *)dependencyManager
{
    NSArray *shareMenuItems = [dependencyManager shareMenuItems];
    NSUInteger count = shareMenuItems.count;
    CGFloat contentHeight = kPreferredRowHeight * ((count + 1) / 2);
    return contentHeight + kShareLabelHeight + kDefaultContentInsets.top + kDefaultContentInsets.bottom;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shareMenuItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VShareItemCollectionViewCell *shareItemCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VShareItemCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
    [shareItemCell populateWithShareMenuItem:self.shareMenuItems[indexPath.row] andBackgroundColor:[self.dependencyManager colorForKey:kOptionsContainerBackgroundKey]];
    return shareItemCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    width -= kInterItemSpace + kDefaultContentInsets.right + kDefaultContentInsets.left;
    width /= kNumberOfColumns;
    return CGSizeMake(width, kPreferredRowHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kInterItemSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kInterItemSpace;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.delegate != nil )
    {
        VShareItemCollectionViewCell *shareItemCell = nil;
        for ( VShareItemCollectionViewCell *cell in collectionView.visibleCells )
        {
            BOOL foundCell = [[collectionView indexPathForCell:cell] isEqual:indexPath];
            if ( foundCell )
            {
                shareItemCell = cell;
                break;
            }
        }
        
        if ( shareItemCell.state == VShareItemCellStateUnselected )
        {
            [self.delegate shareCollectionViewSelectedShareItemCell:shareItemCell];
        }
        else if ( shareItemCell.state == VShareItemCellStateSelected )
        {
            shareItemCell.state = VShareItemCellStateUnselected;
        }
    }
}

#pragma mark - Setters and getters

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.shareMenuItems = [dependencyManager shareMenuItems];
        NSString *shareText = [dependencyManager stringForKey:kShareTextKey];
        self.shareLabel.text = NSLocalizedString(shareText, @"");
        self.shareLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.shareLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
        UIColor *backgroundColor = [dependencyManager colorForKey:kOptionsContainerBackgroundKey];
        self.contentView.backgroundColor = backgroundColor;
        for ( VShareItemCollectionViewCell *cell in self.collectionView.visibleCells )
        {
            [cell updateToBackgroundColor:backgroundColor];
        }
    }
}

- (NSIndexSet *)selectedShareTypes
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for ( VShareItemCollectionViewCell *cell in self.collectionView.visibleCells )
    {
        if ( cell.state == VShareItemCellStateSelected )
        {
            [indexSet addIndex:cell.shareMenuItem.shareType];
        }
    }
    return [indexSet copy];
}

@end
