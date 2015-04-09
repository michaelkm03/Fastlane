//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryViewController.h"

// Data Source
#import "VStreamCollectionViewDataSource.h"

// ViewControllers
#import "VStreamCollectionViewController.h"
#import "VNewContentViewController.h"
#import "VScaffoldViewController.h"

// Views
#import "MBProgressHUD.h"
#import "VDirectoryItemCell.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"

#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VObjectManager.h"
#import "VSettingManager.h"
#import "VDirectoryCellDecorator.h"
#import "NSString+VParseHelp.h"
#import <FBKVOController.h>

#import "VAbstractMarqueeCollectionViewCell.h"
#import "VAbstractMarqueeController.h"
#import "VUserProfileViewController.h"

static CGFloat const kDirectoryInset = 10.0f;

@interface VDirectoryViewController () <UICollectionViewDelegateFlowLayout, VStreamCollectionDataDelegate>

@property (nonatomic, strong) VDirectoryCellDecorator *cellDecorator;

@end

@implementation VDirectoryViewController

#pragma mark - UIView overrides

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cellDecorator = [[VDirectoryCellDecorator alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Layout may have changed between awaking from nib and being added to the container of the SoS
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if ( self.streamDataSource.hasHeaderCell )
    {
        [self.marqueeController enableTimer];
    }
}

- (NSString *)cellIdentifier
{
    return [VDirectoryItemCell suggestedReuseIdentifier];
}

- (UINib *)cellNib
{
    return [VDirectoryItemCell nibForCell];
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self isMarqueeSection:indexPath.section] )
    {
        //Return size for the marqueeCell that is provided by our superclass
        return [self.marqueeController desiredSizeWithCollectionViewBounds:collectionView.bounds];
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    UIEdgeInsets sectionEdgeInsets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
    width -= sectionEdgeInsets.left + sectionEdgeInsets.right + flowLayout.minimumInteritemSpacing;
    width = floorf(width * 0.5f);
    
    BOOL isStreamOfStreamsRow = [[self.streamDataSource itemAtIndexPath:indexPath] isKindOfClass:[VStream class]];
    
    if (((indexPath.row % 2) == 1) && !isStreamOfStreamsRow)
    {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        isStreamOfStreamsRow = [[self.streamDataSource itemAtIndexPath:previousIndexPath] isKindOfClass:[VStream class]];
    }
    
    CGFloat height = isStreamOfStreamsRow ? [VDirectoryItemCell desiredStreamOfStreamsHeightForWidth:width] : [VDirectoryItemCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake(width, height);
}

- (void)navigateToDisplayStreamItem:(VStreamItem *)streamItem
{
    if ( streamItem.isContent )
    {
        VSequence *sequence = (VSequence *)streamItem;
        [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:sequence
                                                                           commentId:nil
                                                                    placeHolderImage:nil];
    }
    else if ( streamItem.isSingleStream )
    {
        VStreamCollectionViewController *viewController = [VStreamCollectionViewController streamViewControllerForStream:(VStream *)streamItem];
        viewController.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ( streamItem.isStreamOfStreams )
    {
        VDirectoryViewController *viewController = [VDirectoryViewController streamDirectoryForStream:(VStream *)streamItem
                                                                                    dependencyManager:self.dependencyManager];
        viewController.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets edgeInsets = [super collectionView:collectionView
                                             layout:collectionViewLayout
                             insetForSectionAtIndex:section];
    
    if ( ![self isMarqueeSection:section] )
    {
        edgeInsets.top += kDirectoryInset;
        edgeInsets.bottom += kDirectoryInset;
        edgeInsets.right += kDirectoryInset;
        edgeInsets.left = kDirectoryInset;
    }
    
    return edgeInsets;
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    
    if ( [self isMarqueeSection:indexPath.section] )
    {
        return [self.marqueeController marqueeCellForCollectionView:self.collectionView atIndexPath:indexPath];
    }
    
    NSString *identifier = [VDirectoryItemCell suggestedReuseIdentifier];
    VDirectoryItemCell *directoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                       forIndexPath:indexPath];
    
    [self.cellDecorator populateCell:directoryCell withStreamItem:item];
    [self.cellDecorator applyStyleToCell:directoryCell withDependencyManager:self.dependencyManager];
    return directoryCell;
}

@end