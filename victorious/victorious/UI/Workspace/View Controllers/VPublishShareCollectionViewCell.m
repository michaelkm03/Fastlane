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
static UIEdgeInsets const kDefaultSectionEdgeInsets = { 4, 10, 12, 10 };
static CGFloat const kShareLabelHeight = 31.0f;
static NSString * const kShareTextKey = @"shareText";
static NSString * const kOptionsContainerBackgroundKey = @"color.background.optionsContainer";

@interface VPublishShareCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UILabel *shareLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *shareMenuItems;
@property (nonatomic, assign) UIEdgeInsets sectionEdgeInsets;

@end

@implementation VPublishShareCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _sectionEdgeInsets = kDefaultSectionEdgeInsets;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib:[VShareItemCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VShareItemCollectionViewCell suggestedReuseIdentifier]];
    self.collectionView.scrollEnabled = NO;
}

- (void)setHorizontalInset:(CGFloat)horizontalInset
{
    UIEdgeInsets updatedInsets = self.sectionEdgeInsets;
    updatedInsets.left = horizontalInset;
    updatedInsets.right = horizontalInset;
    self.sectionEdgeInsets = updatedInsets;
}

+ (CGSize)desiredSizeForCollectionWithBounds:(CGRect)bounds sectionInsets:(UIEdgeInsets)insets andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSArray *shareMenuItems = [dependencyManager shareMenuItems];
    NSUInteger count = shareMenuItems.count;
    if ( count == 0 )
    {
        return CGSizeZero;
    }
    
    CGSize size = bounds.size;
    CGFloat contentHeight = kPreferredRowHeight * ((count + 1) / 2);
    size.height = contentHeight + kShareLabelHeight + kDefaultSectionEdgeInsets.top + kDefaultSectionEdgeInsets.bottom;
    size.width -= insets.left + insets.right;
    return size;
}

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
    [shareItemCell populateWithShareMenuItem:self.shareMenuItems[indexPath.row] andDependencyManager:self.dependencyManager];
    return shareItemCell;
}

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
        self.contentView.backgroundColor = [dependencyManager colorForKey:kOptionsContainerBackgroundKey];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    width -= kInterItemSpace + self.sectionEdgeInsets.right + self.sectionEdgeInsets.left;
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
    return self.sectionEdgeInsets;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.delegate != nil )
    {
        NSUInteger cellIndex = [collectionView.visibleCells indexOfObjectPassingTest:^BOOL(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop)
        {
           
            BOOL foundCell = [[collectionView indexPathForCell:cell] isEqual:indexPath];
            if ( foundCell )
            {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        VShareItemCollectionViewCell *shareItemCell = [[collectionView visibleCells] objectAtIndex:cellIndex];
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
