//
//  VMarqueeController.m
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeController.h"

#import "VStream+Fetcher.h"
#import "VSequence.h"

#import "VStreamCollectionViewDataSource.h"
#import "VMarqueeStreamItemCell.h"
#import "VMarqueeCollectionCell.h"

#import "VGroupedStreamCollectionViewController.h"
#import "VMarqueeTabIndicatorView.h"

#import "VThemeManager.h"
#import "VTimerManager.h"

#import <FBKVOController.h>

@interface VMarqueeController () <VMarqueeCellDelegate>

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;

@property (nonatomic, strong) VStream *stream;
@property (nonatomic, strong) VStreamItem *currentStreamItem;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) VTimerManager *autoScrollTimerManager;

@end

@implementation VMarqueeController

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

- (instancetype)initWithStream:(VStream *)stream
{
    self = [super init];
    if (self)
    {
        _stream = stream;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _currentPage = 0;
        [self addKVOToMarqueeItemsOfStream:stream];
    }
    return self;
}

- (void)dealloc
{
    if (_collectionView.delegate == self)
    {
        _collectionView.delegate = nil;
    }
    [_autoScrollTimerManager invalidate];
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
}

- (void)selectNextTab
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    currentPage ++;
    if (currentPage == (NSInteger)self.stream.marqueeItems.count)
    {
        currentPage = 0;
    }
    
    [self.collectionView setContentOffset:CGPointMake(currentPage * pageWidth, self.collectionView.contentOffset.y) animated:YES];
}

- (void)scrolledToPage:(NSInteger)currentPage
{
    self.tabView.currentlySelectedTab = currentPage;
    self.currentStreamItem = [self.stream.marqueeItems objectAtIndex:currentPage];
    [self enableTimer];
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
}

//Let the container handle the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.marqueeItems objectAtIndex:indexPath.row];
    VMarqueeStreamItemCell *cell = (VMarqueeStreamItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *previewImage = nil;
    if ( [cell isKindOfClass:[VMarqueeStreamItemCell class]] )
    {
        previewImage = cell.previewImageView.image;
    }
    
    [self.selectionDelegate marquee:self selectedItem:item atIndexPath:indexPath previewImage:previewImage];
    [self.autoScrollTimerManager invalidate];
}

- (void)setHideMarqueePosterImage:(BOOL)hideMarqueePosterImage
{
    _hideMarqueePosterImage = hideMarqueePosterImage;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VMarqueeStreamItemCell *marqueeCell, NSUInteger idx, BOOL *stop)
    {
        marqueeCell.hideMarqueePosterImage = hideMarqueePosterImage;
    }];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VMarqueeStreamItemCell *marqueeItemCell, NSUInteger idx, BOOL *stop)
     {
         marqueeItemCell.dependencyManager = dependencyManager;
     }];
}

- (void)setStream:(VStream *)stream
{
    _stream = stream;
    [self addKVOToMarqueeItemsOfStream:stream];
}

- (void)addKVOToMarqueeItemsOfStream:(VStream *)stream
{
    [self.KVOController observe:stream
                        keyPath:@"marqueeItems"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(marqueeItemsUpdated)];
}

- (void)marqueeItemsUpdated
{
    [self.dataDelegate marquee:self reloadedStreamWithItems:[self.stream.marqueeItems array]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    if ( currentPage != self.currentPage )
    {
        self.currentPage = currentPage;
        if ( (NSUInteger) self.currentPage < self.stream.marqueeItems.count )
        {
            [self scrolledToPage:self.currentPage];
        }
    }
}

- (void)disableTimer
{
    [self.autoScrollTimerManager invalidate];
    //Hide all detail boxes here
}

- (void)enableTimer
{
    [self.autoScrollTimerManager invalidate];
    self.autoScrollTimerManager = [VTimerManager scheduledTimerManagerWithTimeInterval:kVDetailVisibilityDuration + kVDetailHideDuration
                                                                                target:self
                                                                              selector:@selector(selectNextTab)
                                                                              userInfo:nil
                                                                               repeats:NO];
    NSInteger currentPage = self.currentPage;
    if ( currentPage < [self collectionView:self.collectionView numberOfItemsInSection:0] )
    {
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VMarqueeStreamItemCell *cell, NSUInteger idx, BOOL *stop)
         {
             if ( [self.collectionView indexPathForCell:cell].row == currentPage )
             {
                 [cell setDetailsContainerVisible:YES animated:NO];
                 [cell restartHideTimer];
                 *stop = YES;
             }
         }];
    }
}

#pragma mark - VMarqueeCellDelegate

- (void)cell:(VMarqueeStreamItemCell *)cell selectedUser:(VUser *)user
{
    [self.selectionDelegate marquee:self selectedUser:user atIndexPath:[self.collectionView indexPathForCell:cell]];
    [self.autoScrollTimerManager invalidate];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.stream.marqueeItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.marqueeItems objectAtIndex:indexPath.row];
    VMarqueeStreamItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VMarqueeStreamItemCell suggestedReuseIdentifier] forIndexPath:indexPath];
    CGSize size = [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
    cell.bounds = CGRectMake(0, 0, size.width, size.height);
    cell.streamItem = item;
    cell.hideMarqueePosterImage = self.hideMarqueePosterImage;
    cell.dependencyManager = self.dependencyManager;
    cell.delegate = self;
    
    return cell;
}

@end
