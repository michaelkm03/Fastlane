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
#import "VDependencyManager.h"
#import "VStreamItem+Fetcher.h"
#import "UIColor+VBrightness.h"
#import "VSequence+Fetcher.h"
#import "VStream.h"
#import "VCompatibility.h"
#import "victorious-Swift.h"

static CGFloat const kStreamDirectoryItemLabelHeight = 34.0f;
static CGFloat const kStreamDirectoryGroupCellBaseWidth = 320.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseHeight = 206.0f;
static CGFloat const kStreamDirectoryGroupCellInset = 10.0f; //Must be >= 1.0f
static NSString * const kGroupedDirectoryCellFactoryKey = @"groupedCell";

@interface VShowcaseDirectoryCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) VCardDirectoryCellDecorator *cellDecorator;
@property (nonatomic, strong) NSObject <VDirectoryCellFactory> *directoryCellFactory;

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
    return VFLOOR( ( kStreamSubdirectoryItemCellBaseHeight * multiplicant ) );
}

+ (CGFloat)desiredCellWidthForBoundsWidth:(CGFloat)width
{
    return VFLOOR( ( width / kStreamDirectoryGroupCellBaseWidth ) * kStreamSubdirectoryItemCellBaseWidth );
}

#pragma mark - View Model

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
 
    if ( dependencyManager != nil )
    {
        self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
        self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
        self.directoryCellFactory = [dependencyManager templateValueConformingToProtocol:@protocol(VDirectoryCellFactory) forKey:kGroupedDirectoryCellFactoryKey];
        NSAssert(self.directoryCellFactory != nil, @"VShowcaseDirectoryCellFactory requires that a valid directory cell factory be returned from the groupedCell of the dependency manager used to create it");
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

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)setDirectoryCellFactory:(NSObject<VDirectoryCellFactory> *)directoryCellFactory
{
    _directoryCellFactory = directoryCellFactory;
    [self registerCellsWithFactory];
}

#pragma mark - Property Accessors

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    [self registerCellsWithFactory];
    
    self.nameLabel.text = [streamItem.name uppercaseString];
    [self.collectionView reloadData];
}

- (void)registerCellsWithFactory
{
    if ( ![self.directoryCellFactory respondsToSelector:@selector(registerCellsWithCollectionView:withStreamItems:)] )
    {
        [self.directoryCellFactory registerCellsWithCollectionView:self.collectionView];
    }
    else
    {
        NSMutableArray *streamItems = [[NSMutableArray alloc] init];
        for ( NSInteger row = 0; row < [self collectionView:self.collectionView numberOfItemsInSection:0]; row++ )
        {
            VStreamItem *streamItem = [self streamItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            if ( streamItem != nil )
            {
                [streamItems addObject:streamItem];
            }
        }
        [self.directoryCellFactory registerCellsWithCollectionView:self.collectionView withStreamItems:streamItems];
    }
}

- (VStream *)stream
{
    if ( [self.streamItem isKindOfClass:[VStream class]] )
    {
        return (VStream *)self.streamItem;
    }
    return nil;
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
    
    VStream *stream = [self stream];
    return stream.streamItems.count + 1; //Add one for the "show more" cell
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.directoryCellFactory collectionView:collectionView cellForStreamItem:[self streamItemAtIndexPath:indexPath] atIndexPath:indexPath];
}

- (BOOL)hasSequenceStream
{
    return [self stream] == nil;
}

- (BOOL)hasStreamOfStreams
{
    if ( [self hasSequenceStream] )
    {
        return NO;
    }
    
    for ( VStreamItem *streamItem in [self stream].streamItems )
    {
        if ( [streamItem isStreamOfStreams] )
        {
            return YES;
        }
    }
    
    return NO;
}

- (VStreamItem *)streamItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem = self.streamItem;
    VStream *stream = [self stream];
    if ( stream != nil )
    {
        NSArray<VStreamItem *> *streamItems = stream.streamItems;
        if ( (NSUInteger)indexPath.row < streamItems.count )
        {
            streamItem = streamItems[indexPath.row];
        }
        else
        {
            streamItem = nil;
        }
    }
    return streamItem;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id <VShowcaseDirectorySelection> responder = [self targetForAction:@selector(showcaseDirectoryCell:didSelectStreamItem:)
                                                            withSender:nil];
    if ( responder != nil )
    {
        VStreamItem *streamItem = [self streamItemAtIndexPath:indexPath];
        if ( streamItem == nil )
        {
            streamItem = self.streamItem;
        }
        [responder showcaseDirectoryCell:self didSelectStreamItem:streamItem];
    }
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat height = [VShowcaseDirectoryCell directoryCellHeightForWidth:width];
    VStream *stream = [self stream];
    if ( stream.isStreamOfStreams )
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
