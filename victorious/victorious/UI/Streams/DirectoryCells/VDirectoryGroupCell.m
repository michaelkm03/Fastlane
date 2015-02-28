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

// Models
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "UIColor+VBrightness.h"

CGFloat const kStreamDirectoryGroupCellInset = 10.0f; //Must be >= 1.0f
static CGFloat const kStreamDirectoryItemLabelHeight = 34.0f;
static CGFloat const kStreamDirectoryGroupCellBaseWidth = 320.0f;

static CGFloat const kStreamSubdirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseHeight = 206.0f;

@interface VDirectoryGroupCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, readwrite) BOOL isStreamOfStreamsRow;

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
    _dependencyManager = dependencyManager;
    
    self.nameLabel.font = [_dependencyManager fontForKey:@"font.header"];
    self.nameLabel.textColor = [_dependencyManager colorForKey:@"color.text"];
    
    NSDictionary *component = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"cell.directory.item"];
    self.itemCellDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:component];
    
    [self.collectionView reloadData];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self registerNibWithName:NSStringFromClass([VDirectoryItemCell class])];
    [self registerNibWithName:NSStringFromClass([VDirectorySeeMoreItemCell class])];
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
    
    //Check if item is last in number of items in section, this is the "show more" cell
    if ( indexPath.item == 10 )
    {
        NSString *identifier = NSStringFromClass([VDirectorySeeMoreItemCell class]);
        VDirectorySeeMoreItemCell *seeMoreCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                forIndexPath:indexPath];
        seeMoreCell.borderColor = [self.itemCellDependencyManager colorForKey:@"color.text.accent"];
        seeMoreCell.imageColor = [self.itemCellDependencyManager colorForKey:@"color.text"];
        seeMoreCell.backgroundColor = [self.itemCellDependencyManager colorForKey:@"color.background"];
        
        seeMoreCell.seeMoreLabel.textColor = [self.itemCellDependencyManager colorForKey:@"color.text.accent"];
        seeMoreCell.seeMoreLabel.font = [self.itemCellDependencyManager fontForKey:@"seeMoreLabelFont"];
        
        [seeMoreCell updateBottomConstraintToConstant:self.isStreamOfStreamsRow ? kDirectoryItemStackHeight : 0.0f];
        
        cell = seeMoreCell;
    }
    else
    {
        //Populate streamItem from item in stream instead of top-level stream item
        NSString *identifier = NSStringFromClass([VDirectoryItemCell class]);
        VDirectoryItemCell *directoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                           forIndexPath:indexPath];
        directoryCell.streamItem = item;
        
        directoryCell.stackBorderColor = [self.itemCellDependencyManager colorForKey:@"color.text.accent"];
        UIColor *borderColor = [self.itemCellDependencyManager colorForKey:@"color.background"];
        directoryCell.stackBackgroundColor = [borderColor v_colorDarkenedByRelativeAmount:0.2f];
        
        directoryCell.nameLabel.font = [self.itemCellDependencyManager fontForKey:@"itemLabelFont"];
        directoryCell.nameLabel.textColor = [self.itemCellDependencyManager colorForKey:@"color.text.accent"];
        
        directoryCell.countLabel.textColor = [self.itemCellDependencyManager colorForKey:@"color.text"];
        directoryCell.countLabel.font = [self.itemCellDependencyManager fontForKey:@"itemQuantityFont"];
        
        cell = directoryCell;
    }
    
    return cell;
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
    if ( self.isStreamOfStreamsRow )
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
