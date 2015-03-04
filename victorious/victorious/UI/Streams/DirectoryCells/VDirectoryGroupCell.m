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
@property (nonatomic, readwrite) BOOL isStreamOfStreamsRow;
@property (nonatomic, weak, readwrite) VStream *stream;

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
    
    NSDictionary *component = [_dependencyManager templateValueOfType:[NSDictionary class] forKey:@"cell.directory.item"];
    self.itemCellDependencyManager = [_dependencyManager childDependencyManagerWithAddedConfiguration:component];
    
    [self.collectionView reloadData];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
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

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    if ([_streamItem isKindOfClass:[VStream class]])
    {
        self.stream = (VStream *)self.streamItem;
    }
    
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
    return MIN( self.stream.streamItems.count, VDirectoryMaxItemsPerGroup + (NSUInteger)1 );
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backgroundColor = [self.itemCellDependencyManager colorForKey:@"color.background"];
    UIColor *borderColor = [self.itemCellDependencyManager colorForKey:@"color.accent"];
    UIColor *textColor = [self.itemCellDependencyManager colorForKey:@"color.text"];
    UIColor *secondaryTextColor = [self.itemCellDependencyManager colorForKey:@"color.text.accent"];
    
    //Check if item is last in number of items in section, this is the "show more" cell
    if ( indexPath.item == VDirectoryMaxItemsPerGroup )
    {
        NSString *identifier = [VDirectorySeeMoreItemCell suggestedReuseIdentifier];
        VDirectorySeeMoreItemCell *seeMoreCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                forIndexPath:indexPath];
                                     
        seeMoreCell.borderColor = borderColor;
        seeMoreCell.imageColor = [self.itemCellDependencyManager colorForKey:@"color.accent.secondary"];
        seeMoreCell.backgroundColor = backgroundColor;
        seeMoreCell.seeMoreLabel.textColor = [self.itemCellDependencyManager colorForKey:@"text.color.content"];
        seeMoreCell.seeMoreLabel.font = [self.itemCellDependencyManager fontForKey:@"seeMoreLabelFont"];
        
        [seeMoreCell updateBottomConstraintToConstant:self.isStreamOfStreamsRow ? kDirectoryItemStackHeight : 0.0f];
        
        return seeMoreCell;
    }
    else
    {
        //Populate streamItem from item in stream instead of top-level stream item
        NSString *identifier = [VDirectoryItemCell suggestedReuseIdentifier];
        VDirectoryItemCell *directoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                           forIndexPath:indexPath];
        
        directoryCell.stackBorderColor = borderColor;
        directoryCell.stackBackgroundColor = backgroundColor;
        
        directoryCell.nameLabel.font = [self.itemCellDependencyManager fontForKey:@"itemLabelFont"];
        directoryCell.nameLabel.textColor = textColor;
        
        directoryCell.countLabel.textColor = secondaryTextColor;
        directoryCell.countLabel.font = [self.itemCellDependencyManager fontForKey:@"itemQuantityFont"];
        
        // Common data
        VStreamItem *streamItem = self.stream.streamItems[ indexPath.row ];
        directoryCell.nameLabel.text = streamItem.name;
        [directoryCell setPreviewImagePath:[streamItem.previewImagePaths firstObject] placeholderImage:nil];
        directoryCell.showVideo = NO;
        
        // Model-specific data
        if ( [streamItem isKindOfClass:[VStream class]] )
        {
            VStream *stream = (VStream *)streamItem;
            if ( stream.isStreamOfStreams )
            {
                directoryCell.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ STREAMS", @""), stream.count];
                directoryCell.showStackedBackground = YES;
            }
            else
            {
                directoryCell.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ITEMS", @""), stream.count];
                directoryCell.showStackedBackground = NO;
            }
        }
        else if ( [streamItem isKindOfClass:[VSequence class]] )
        {
            VSequence *sequence = (VSequence *)streamItem;
            directoryCell.showVideo = [sequence isVideo];
            directoryCell.showStackedBackground = NO;
            directoryCell.nameLabel.text = sequence.name;
            directoryCell.countLabel.text = @"";
        }
        
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
