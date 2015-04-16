//
//  VAbstractMarqueeController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeController.h"
#import "VAbstractMarqueeCollectionViewCell.h"
#import "VAbstractMarqueeStreamItemCell.h"
#import "VTimerManager.h"
#import "VStreamItem.h"
#import "VStream+Fetcher.h"
#import "VDependencyManager.h"
#import "NSString+VParseHelp.h"
#import "VObjectManager.h"
#import "VDependencyManager+VObjectManager.h"
#import <FBKVOController.h>
#import "VURLMacroReplacement.h"

static NSString * const kStreamURLKey = @"streamURL";
static NSString * const kSequenceIDKey = @"sequenceID";
static NSString * const kSequenceIDMacro = @"%%SEQUENCE_ID%%";
static const CGFloat kDefaultMarqueeTimerFireDuration = 5.0f;

@interface VAbstractMarqueeController ()

@property (nonatomic, readwrite) NSUInteger currentPage;
@property (nonatomic, readwrite) VTimerManager *autoScrollTimerManager;
@property (nonatomic, readwrite) VStreamItem *currentStreamItem;

@end

@implementation VAbstractMarqueeController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        NSString *url = [dependencyManager stringForKey:kStreamURLKey];
        
        NSString *sequenceID = [dependencyManager stringForKey:kSequenceIDKey];
        if ( sequenceID != nil )
        {
            VURLMacroReplacement *urlMacroReplacement = [[VURLMacroReplacement alloc] init];
            url = [urlMacroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ kSequenceIDMacro: sequenceID }
                                                                       inURLString:url];
        }
        NSString *path = [url v_pathComponent];
        
        if ( path != nil )
        {
            _stream = [VStream streamForPath:path inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
            [self setupWithStream:_stream];
        }
        _dependencyManager = dependencyManager;
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

- (NSString *)cellSuggestedReuseIdentifier
{
    return [VAbstractMarqueeStreamItemCell suggestedReuseIdentifier];
}

#pragma mark - stream updating

- (void)setStream:(VStream *)stream
{
    _stream = stream;
    [self setupWithStream:stream];
}

- (void)setupWithStream:(VStream *)stream
{
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.currentPage = 0;
    [self addKVOToMarqueeItemsOfStream:stream];
}

- (void)addKVOToMarqueeItemsOfStream:(VStream *)stream
{
    [self.KVOController observe:stream
                        keyPath:[self marqueeItemsKeyPath]
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(marqueeItemsUpdated)];
}

- (NSString *)marqueeItemsKeyPath
{
    return NSStringFromSelector(@selector(marqueeItems));
}

- (void)marqueeItemsUpdated
{
    [self.dataDelegate marquee:self reloadedStreamWithItems:[self.stream.marqueeItems array]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    if ( currentPage != self.currentPage )
    {
        self.currentPage = currentPage;
        if ( self.currentPage < self.stream.marqueeItems.count )
        {
            [self scrolledToPage:self.currentPage];
        }
    }
}

- (void)selectNextTab
{
    CGFloat pageWidth = CGRectGetWidth(self.collectionView.bounds);
    NSUInteger currentPage = ( self.collectionView.contentOffset.x / pageWidth ) + 1;
    if (currentPage == self.stream.marqueeItems.count)
    {
        currentPage = 0;
    }
    
    [self.collectionView setContentOffset:CGPointMake(currentPage * pageWidth, self.collectionView.contentOffset.y) animated:YES];
}

- (void)scrolledToPage:(NSInteger)currentPage
{
    self.currentStreamItem = [self.stream.marqueeItems objectAtIndex:currentPage];
    [self enableTimer];
}

- (void)disableTimer
{
    [self.autoScrollTimerManager invalidate];
    //Hide all detail boxes here
}

- (void)enableTimer
{
    [self.autoScrollTimerManager invalidate];
    self.autoScrollTimerManager = [VTimerManager scheduledTimerManagerWithTimeInterval:[self timerFireInterval]
                                                                                target:self
                                                                              selector:@selector(selectNextTab)
                                                                              userInfo:nil
                                                                               repeats:NO];
}

- (NSTimeInterval)timerFireInterval
{
    return kDefaultMarqueeTimerFireDuration;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.stream.marqueeItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self desiredSizeWithCollectionViewBounds:collectionView.bounds];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

//Let the container handle the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = self.stream.marqueeItems[indexPath.row];
    VAbstractMarqueeStreamItemCell *cell = (VAbstractMarqueeStreamItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *previewImage = cell.previewImageView.image;
    
    [self.selectionDelegate marquee:self selectedItem:item atIndexPath:indexPath previewImage:previewImage];
    [self.autoScrollTimerManager invalidate];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.marqueeItems objectAtIndex:indexPath.row];
    VAbstractMarqueeStreamItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[self cellSuggestedReuseIdentifier] forIndexPath:indexPath];
    cell.streamItem = item;
    cell.dependencyManager = self.dependencyManager;
    
    return cell;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).sectionInset = UIEdgeInsetsZero;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    for ( VAbstractMarqueeStreamItemCell *marqueeItemCell in self.collectionView.visibleCells )
    {
        marqueeItemCell.dependencyManager = dependencyManager;
    }
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSAssert(false, @"registerCellsWithCollectionView: must be implemented by subclasses of VAbstractMarqueeCellFactory");
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(false, @"marqueeCellForCollectionView:atIndexPath: must be implemented by subclasses of VAbstractMarqueeCellFactory");
    return nil;
}

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"Subclasses must override desiredSizeWithCollectionViewBounds: in VAbstractMarqueeController");
    return CGSizeZero;
}

@end
