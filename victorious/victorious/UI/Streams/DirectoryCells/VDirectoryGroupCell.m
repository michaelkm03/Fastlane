//
//  VDirectoryGroupCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryGroupCell.h"
#import "VDirectoryItemCell.h"
#import "VDirectorySeeMoreItemCell.h"
#import "VDirectoryCellDecorator.h"

// Models
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "UIColor+VBrightness.h"
#import "VSequence+Fetcher.h"

const NSUInteger VDirectoryMaxItemsPerGroup = 10;

CGFloat const kStreamDirectoryGroupCellInset = 10.0f; //Must be >= 1.0f
static CGFloat const kStreamDirectoryItemLabelHeight = 34.0f;
static CGFloat const kStreamDirectoryGroupCellBaseWidth = 320.0f;

static CGFloat const kStreamSubdirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseHeight = 206.0f;

@interface VDirectoryGroupCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) VDirectoryCellDecorator *cellDecorator;
@property (nonatomic, strong) VDependencyManager *itemCellDependencyManager;

@end

@implementation VDirectoryGroupCell

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
    return [self directoryCellHeightForWidth:width] + kStreamDirectoryItemLabelHeight + kStreamDirectoryGroupCellInset;
}

+ (CGFloat)directoryCellHeightForWidth:(CGFloat)width
{
    CGFloat multiplicant = width / kStreamDirectoryGroupCellBaseWidth;
    return ( kStreamSubdirectoryItemCellBaseHeight * multiplicant );
}

+ (CGFloat)desiredCellWidthForBoundsWidth:(CGFloat)width
{
    return ( width / kStreamDirectoryGroupCellBaseWidth ) * kStreamSubdirectoryItemCellBaseWidth;
}

#pragma mark - View Model

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.nameLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    self.nameLabel.textColor = [self.dependencyManager colorForKey:@"color.text"];
    
    NSDictionary *component = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"cell.directory.item"];
    self.itemCellDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:component];
    
    [self.collectionView reloadData];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cellDecorator = [[VDirectoryCellDecorator alloc] init];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerNib:[VDirectoryItemCell nibForCell]
          forCellWithReuseIdentifier:[VDirectoryItemCell suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VDirectorySeeMoreItemCell nibForCell]
          forCellWithReuseIdentifier:[VDirectorySeeMoreItemCell suggestedReuseIdentifier]];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Property Accessors

- (void)setStream:(VStream *)stream
{
    _stream = stream;
    
    self.nameLabel.text = [stream.name uppercaseString];
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
    return MIN( self.stream.streamItems.count, VDirectoryMaxItemsPerGroup + (NSUInteger)1 );
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Check if item is last in number of items in section, this is the "show more" cell
    if ( indexPath.item == VDirectoryMaxItemsPerGroup )
    {
        NSString *identifier = [VDirectorySeeMoreItemCell suggestedReuseIdentifier];
        VDirectorySeeMoreItemCell *seeMoreCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                forIndexPath:indexPath];
        [self.cellDecorator applyStyleToSeeMoreCell:seeMoreCell withDependencyManager:self.itemCellDependencyManager];
        
        return seeMoreCell;
    }
    else
    {
        //Populate streamItem from item in stream instead of top-level stream item
        NSString *identifier = [VDirectoryItemCell suggestedReuseIdentifier];
        VDirectoryItemCell *directoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                           forIndexPath:indexPath];
        VStreamItem *streamItem = self.stream.streamItems[ indexPath.row ];
        [self.cellDecorator populateCell:directoryCell withStreamItem:streamItem];
        [self.cellDecorator applyStyleToCell:directoryCell withDependencyManager:self.itemCellDependencyManager];
        
        return directoryCell;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate streamDirectoryGroupCell:self didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat height = [VDirectoryGroupCell directoryCellHeightForWidth:width];
    if ( self.stream.isStreamOfStreams )
    {
        height += kDirectoryItemStackHeight;
    }
    
    return CGSizeMake([VDirectoryGroupCell desiredCellWidthForBoundsWidth:width], height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0f,
                            kStreamDirectoryGroupCellInset,
                            kStreamDirectoryGroupCellInset,
                            kStreamDirectoryGroupCellInset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kStreamDirectoryGroupCellInset;
}

@end
