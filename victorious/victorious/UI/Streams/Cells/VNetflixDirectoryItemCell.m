//
//  VNetflixDirectoryItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNetflixDirectoryItemCell.h"

#import "VDirectoryItemCell.h"

//theme
#import "VThemeManager.h"

// Models
#import "VStream.h"
#import "VStreamItem+Fetcher.h"

/*
// Views
#import "VExtendedView.h"

// Categories
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"

// Models
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
 */

NSString * const VNetflixDirectoryItemCellNameStream = @"VStreamNetflixDirectoryItemCell";
static CGFloat const kNetflixDirectoryItemCellInset = 10.0f;

@interface VNetflixDirectoryItemCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation VNetflixDirectoryItemCell

#pragma mark - Sizing Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds) * .453; //from spec, 290 width on 640
    return CGSizeMake(width, [self desiredStreamOfStreamsHeightForWidth:width]);
}

+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width
{
    return (kDirectoryItemBaseHeight - kDirectoryItemBaseWidth) + ((kDirectoryItemBaseWidth * width) / kDirectoryItemBaseWidth) + kDirectoryItemStackHeight;
}

+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width
{
    return [self desiredStreamOfStreamsHeightForWidth:width];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    UINib *nib = [UINib nibWithNibName:VDirectoryItemCellNameStream bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VDirectoryItemCellNameStream];
}

#pragma mark - Property Accessors

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    
#warning SETUP ARRAYS FOR COLLECTIONVIEW DATASOURCE HERE
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
#warning RESTORE DATASOURCE ARRAYS TO EMPTY
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
#warning THIS WILL CHANGE TO GET THE NEW FIELD FROM THE STREAM ITEM (OR STREAM!?!)
    return 1;// self.streamItem.streams.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = self.streamItem;
    VNetflixDirectoryItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VDirectoryItemCellNameStream forIndexPath:indexPath];
    cell.streamItem = item;
    
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
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    width = width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing;
    width = floorf(width * 0.4f);
    
    BOOL isStreamOfStreamsRow = [[(VDirectoryItemCell *)[self.collectionView cellForItemAtIndexPath:indexPath] streamItem] isKindOfClass:[VStream class]];
    
    CGFloat height = isStreamOfStreamsRow ? [VNetflixDirectoryItemCell desiredStreamOfStreamsHeightForWidth:width] : [VNetflixDirectoryItemCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kNetflixDirectoryItemCellInset,
                            kNetflixDirectoryItemCellInset,
                            0,
                            kNetflixDirectoryItemCellInset);
}

@end
