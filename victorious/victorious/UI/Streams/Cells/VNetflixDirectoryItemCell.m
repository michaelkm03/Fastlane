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
CGFloat const kNetflixDirectoryItemCellInset = 10.0f; //Must be >= 1.0f
static CGFloat const kNetflixDirectoryItemLabelHeight = 34.0f;
static CGFloat const kNetflixDirectoryItemCellBaseWidth = 320.0f;

static CGFloat const kNetflixSubDirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kNetflixSubDirectoryItemCellBaseHeight = 206.0f;

@interface VNetflixDirectoryItemCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, readwrite) BOOL isStreamOfStreamsRow;
@property (nonatomic, strong) UIColor *seeMoreAndHeaderTextColor;

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
    return [self directoryCellHeightForWidth:width] + kNetflixDirectoryItemLabelHeight + kNetflixDirectoryItemCellInset;
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
    
    self.seeMoreAndHeaderTextColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.nameLabel.textColor = self.seeMoreAndHeaderTextColor;
    
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
    [self.collectionView setContentOffset:CGPointZero animated:NO];
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
    VBaseCollectionViewCell *cell;
    
    UIColor *borderColor = [UIColor blackColor];
    UIColor *backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:39.0f/255.0f blue:43.0f/255.0f alpha:1.0f];
    
    //Check if item is last in number of items in section, this is the "show more" cell
    if ( indexPath.item == 10)
    {
        VSeeMoreDirectoryItemCell *seeMoreCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VSeeMoreDirectoryItemCellNameStream forIndexPath:indexPath];
        seeMoreCell.borderColor = borderColor;
        seeMoreCell.backgroundColor = backgroundColor;
        seeMoreCell.seeMoreLabel.textColor = self.seeMoreAndHeaderTextColor;
        [seeMoreCell updateBottomConstraintToConstant:self.isStreamOfStreamsRow ? kDirectoryItemStackHeight : 0.0f];
        cell = seeMoreCell;
    }
    else
    {
        //Populate streamItem from item in stream instead of top-level stream item
        VDirectoryItemCell *directoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VDirectoryItemCellNameStream forIndexPath:indexPath];
        directoryCell.streamItem = item;
        directoryCell.stackBorderColor = borderColor;
        directoryCell.stackBackgroundColor = backgroundColor;
        directoryCell.nameLabel.textColor = [UIColor whiteColor];
        directoryCell.countLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        cell = directoryCell;
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
    return UIEdgeInsetsMake(0.0f,
                            kNetflixDirectoryItemCellInset,
                            kNetflixDirectoryItemCellInset,
                            kNetflixDirectoryItemCellInset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kNetflixDirectoryItemCellInset;
}

@end
