//
//  VShowcaseDirectoryCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShowcaseDirectoryCell.h"
#import "VCardDirectoryCell.h"
#import "VCardSeeMoreDirectoryCell.h"
#import "VCardDirectoryCellDecorator.h"

// Models
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "UIColor+VBrightness.h"
#import "VSequence+Fetcher.h"

static CGFloat const kStreamDirectoryItemLabelHeight = 34.0f;
static CGFloat const kStreamDirectoryGroupCellBaseWidth = 320.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseHeight = 206.0f;
static CGFloat const kStreamDirectoryGroupCellInset = 10.0f; //Must be >= 1.0f

@interface VShowcaseDirectoryCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) VCardDirectoryCellDecorator *cellDecorator;

@end

@implementation VShowcaseDirectoryCell

#pragma mark - Sizing Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    return CGSizeMake(width, [self desiredStreamOfStreamsHeightForWidth:width]);
}

+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width
{
    return [self desiredStreamOfContentHeightForWidth:width] + VDirectoryItemStackHeight;
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
    _dependencyManager = dependencyManager;
 
    if ( dependencyManager != nil )
    {
        self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
        self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cellDecorator = [[VCardDirectoryCellDecorator alloc] init];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.contentInset = UIEdgeInsetsZero;
}

- (void)setDirectoryCellFactory:(NSObject<VDirectoryCellFactory> *)directoryCellFactory
{
    _directoryCellFactory = directoryCellFactory;
    [_directoryCellFactory registerCellsWithCollectionView:self.collectionView];
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
    if ( [self hasSequenceStream] )
    {
        return 1;
    }
    return self.stream.streamItems.count + ([self shouldShowShowMore] ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.directoryCellFactory collectionView:collectionView cellForIndexPath:indexPath withStreamItem:[self streamItemAtIndexPath:indexPath]];
}

- (BOOL)hasSequenceStream
{
    return [self.stream isKindOfClass:[VSequence class]];
}

- (BOOL)hasStreamOfStreams
{
    if ( ![self.stream isKindOfClass:[VStream class]] )
    {
        return NO;
    }
    
    for ( VStreamItem *streamItem in self.stream.streamItems )
    {
        if ( [streamItem isStreamOfStreams] )
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldShowShowMore
{
    if ([self.stream.count integerValue] > (NSInteger)self.stream.streamItems.count)
    {
        return YES;
    }
    return NO;
}

- (VStreamItem *)streamItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem = nil;
    if ( [self.stream isKindOfClass:[VSequence class]] )
    {
        return self.stream;
    }
    else if ( [self.stream isKindOfClass:[VStream class]] )
    {
        NSOrderedSet *streamItems = self.stream.streamItems;
        if ( (NSUInteger)indexPath.row < streamItems.count )
        {
            streamItem = streamItems[indexPath.row];
        }   
    }
    return streamItem;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate showcaseDirectoryCell:self didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat height = [VShowcaseDirectoryCell directoryCellHeightForWidth:width];
    if ( self.stream.isStreamOfStreams )
    {
        height += VDirectoryItemStackHeight;
    }
    
    return CGSizeMake([VShowcaseDirectoryCell desiredCellWidthForBoundsWidth:width], height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kStreamDirectoryGroupCellInset;
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

@end
