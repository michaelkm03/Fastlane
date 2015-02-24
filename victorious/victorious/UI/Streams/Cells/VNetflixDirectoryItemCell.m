//
//  VNetflixDirectoryItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNetflixDirectoryItemCell.h"

#import "VDirectoryItemCell.h"
#import "VSeeMoreDirectoryItemCell.h"

//theme
#import "VThemeManager.h"

// Models
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"

NSString * const VNetflixDirectoryItemCellNameStream = @"VStreamNetflixDirectoryItemCell";
static CGFloat const kNetflixDirectoryItemCellInset = 8.0f; //Must be >= 1.0f
static CGFloat const kNetflixDirectoryItemLabelHeight = 34.0f;
static CGFloat const kNetflixDirectoryItemCellBaseWidth = 320.0f;

static CGFloat const kNetflixSubDirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kNetflixSubDirectoryItemCellBaseHeight = 206.0f;

@interface VNetflixDirectoryItemCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, readwrite) BOOL isStreamOfStreamsRow;

@end

@implementation VNetflixDirectoryItemCell

#pragma mark - Sizing Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    return CGSizeMake(width, [self desiredStreamOfStreamsHeightForWidth:width]);
}

+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width
{
    return [self desiredStreamOfContentHeightForWidth:width] + kDirectoryItemStackHeight;
}

+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width
{
    return [self directoryCellHeightForWidth:width] + kNetflixDirectoryItemLabelHeight + kNetflixDirectoryItemCellInset * 2;
}

+ (CGFloat)directoryCellHeightForWidth:(CGFloat)width
{
    CGFloat multiplicant = width / kNetflixDirectoryItemCellBaseWidth;
    return ( kNetflixSubDirectoryItemCellBaseHeight * multiplicant );
}

+ (CGFloat)desiredCellWidthForBoundsWidth:(CGFloat)width
{
    return ( width / kNetflixDirectoryItemCellBaseWidth ) * kNetflixSubDirectoryItemCellBaseWidth;
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self registerNibWithName:VDirectoryItemCellNameStream];
    [self registerNibWithName:VSeeMoreDirectoryItemCellNameStream];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.contentInset = UIEdgeInsetsZero;
}

- (void)registerNibWithName:(NSString *)nibName
{
    [self.collectionView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:nibName];
}

#pragma mark - Property Accessors

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.isStreamOfStreamsRow = [self.streamItem isKindOfClass:[VStream class]] && [(VStream *)self.streamItem isStreamOfStreams];
    self.nameLabel.text = [streamItem.name uppercaseString];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.collectionView setContentOffset:CGPointZero];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 11; //Should be something like self.streamItem.streams.count + 1; the +1 will be for the "see more" cell
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = self.streamItem;
    VNetflixDirectoryItemCell *cell;
    
    //Check if item is last in number of items in section, this is the "show more" cell
    if ( indexPath.item == 10)
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VSeeMoreDirectoryItemCellNameStream forIndexPath:indexPath];
        [(VSeeMoreDirectoryItemCell *)cell updateBottomConstraintToConstant:self.isStreamOfStreamsRow ? kDirectoryItemStackHeight : 0.0f];
    }
    else
    {
        //Populate streamItem from item in stream instead of top-level stream item
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VDirectoryItemCellNameStream forIndexPath:indexPath];
        cell.streamItem = item;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate netflixDirectoryItemCell:self didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat height = [VNetflixDirectoryItemCell directoryCellHeightForWidth:width];
    if ( self.isStreamOfStreamsRow )
    {
        height += kDirectoryItemStackHeight;
    }
    
    return CGSizeMake([VNetflixDirectoryItemCell desiredCellWidthForBoundsWidth:width], height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kNetflixDirectoryItemCellInset / 2.0f,
                            kNetflixDirectoryItemCellInset,
                            kNetflixDirectoryItemCellInset / 2.0f,
                            kNetflixDirectoryItemCellInset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kNetflixDirectoryItemCellInset;
}

@end
