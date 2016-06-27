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
#import "VStreamItem+Fetcher.h"
#import "VDependencyManager.h"
#import "NSString+VParseHelp.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "VStreamTrackingHelper.h"
#import "VFocusable.h"
#import "VStreamItemPreviewView.h"
#import "victorious-Swift.h"

@import KVOController;

NSString * const VStreamURLKey = @"streamURL";
NSString * const VSequenceIDKey = @"sequenceID";
NSString * const VSequenceIDMacro = @"%%SEQUENCE_ID%%";

static const CGFloat kDefaultMarqueeTimerFireDuration = 5.0f;

@interface VAbstractMarqueeController ()

@property (nonatomic, readwrite) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger currentFocusPage;
@property (nonatomic, readwrite) VTimerManager *autoScrollTimerManager;
@property (nonatomic, strong) NSMutableSet *registeredReuseIdentifiers;
@property (nonatomic, strong) VStreamItem *selectedItem;

@property (nonatomic, strong) VStreamTrackingHelper *streamTrackingHelper;

@end

@implementation VAbstractMarqueeController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _registeredReuseIdentifiers = [[NSMutableSet alloc] init];
        _streamTrackingHelper = [[VStreamTrackingHelper alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(disableScroll)
                                                     name:VSessionTimerNewSessionShouldStart
                                                   object:nil];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)disableScroll
{
    [self disableTimer];
    self.collectionView.userInteractionEnabled = NO;
}

- (void)dealloc
{
    if (_collectionView.delegate == self)
    {
        _collectionView.delegate = nil;
    }
    [_autoScrollTimerManager invalidate];
}

#pragma mark - stream updating

- (void)setShelf:(Shelf *)shelf
{
    if ( shelf == _shelf )
    {
        return;
    }
    
    _shelf = shelf;
    [self reset];
    [self marqueeItemsUpdated];
}

- (VStream *)currentStream
{
    return self.shelf;
}

- (NSArray *)marqueeItems
{
    return self.shelf.streamItems;
}

- (CGFloat)pageWidth
{    
    Class<VSharedCollectionReusableViewMethods> itemCellClass = [self.class marqueeStreamItemCellClass];
    return [itemCellClass desiredSizeWithCollectionViewBounds:self.collectionView.bounds].width;
}

- (void)reset
{
    self.currentPage = 0;
    self.currentFocusPage = 0;
}

- (void)marqueeItemsUpdated
{
    NSArray *marqueeItems = self.marqueeItems;
    [self.dataDelegate marqueeController:self reloadedStreamWithItems:marqueeItems];
    [self registerStreamItemCellsWithCollectionView:self.collectionView forMarqueeItems:marqueeItems];
    [self.collectionView reloadData];
    [self enableTimer];
    [self updateFocus];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger currentPage = self.collectionView.contentOffset.x / self.pageWidth;
    if ( currentPage != self.currentPage )
    {
        self.currentPage = currentPage;
        if ( self.currentPage < self.marqueeItems.count )
        {
            [self scrolledToPage:self.currentPage];
        }
    }
    
    [self updateFocus];
    
    [self updateCellVisibilityTracking];
}

- (void)updateFocus
{
    //Update the focus of preview views that conform to VCellFocus
    NSInteger currentFocusPage = ( self.collectionView.contentOffset.x + self.pageWidth / 2 ) / self.pageWidth;
    currentFocusPage = MIN( currentFocusPage, (NSInteger)self.marqueeItems.count - 1 );
    currentFocusPage = MAX( currentFocusPage, 0 );

    if ( self.marqueeItems.count > (NSUInteger)currentFocusPage )
    {
        self.currentFocusPage = currentFocusPage;
        VStreamItem *focusedStreamItem = self.marqueeItems[currentFocusPage];
        for ( VAbstractMarqueeStreamItemCell *cell in self.collectionView.visibleCells )
        {
            const BOOL isSelectedCell = self.selectedItem != nil && [cell.previewView.streamItem isEqual:self.selectedItem];
            if ( [cell.previewView conformsToProtocol:@protocol(VFocusable)] && !isSelectedCell )
            {
                BOOL hasFocus = [focusedStreamItem isEqual:cell.streamItem];
                VFocusType focusType = hasFocus ? VFocusTypeStream : VFocusTypeNone;
                [(VStreamItemPreviewView <VFocusable> *)cell.previewView setFocusType:focusType];
            }
        }
    }
}

- (void)endFocusOnAllCells
{
    self.currentFocusPage = 0;
    
    for ( VAbstractMarqueeStreamItemCell *cell in self.collectionView.visibleCells )
    {
        const BOOL isSelectedCell = self.selectedItem != nil && [cell.previewView.streamItem isEqual:self.selectedItem];
        if ( !isSelectedCell )
        {
            if ( [cell.previewView conformsToProtocol:@protocol(VFocusable)] )
            {
                [(VStreamItemPreviewView <VFocusable> *)cell.previewView setFocusType:VFocusTypeNone];
            }
        }
    }
}

- (void)selectNextTab
{
    if ( self.marqueeItems.count == 1 )
    {
        //We've locked the scrolling, meaning we shouldn't have it animate either
        return;
    }
    
    NSUInteger currentPage = ( self.collectionView.contentOffset.x / self.pageWidth ) + 1;
    if (currentPage == self.marqueeItems.count)
    {
        currentPage = 0;
    }
    
    [self.collectionView setContentOffset:CGPointMake(currentPage * self.pageWidth, self.collectionView.contentOffset.y) animated:YES];
}

- (void)scrolledToPage:(NSInteger)currentPage
{
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

#pragma mark - Cell visibility

- (void)updateCellVisibilityTracking
{
    const CGRect streamVisibleRect = self.collectionView.bounds;
    
    NSArray *visibleCells = self.collectionView.visibleCells;
    [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop)
     {
         // Calculate visible ratio for the whole cell
         const CGRect intersection = CGRectIntersection( streamVisibleRect, cell.frame );
         const CGFloat visibleRatio = CGRectGetWidth( intersection ) / CGRectGetWidth( cell.frame );
         CGFloat roundedRatio = VCEIL(visibleRatio * 100) / 100;
         [self collectionViewCell:cell didUpdateCellVisibility:roundedRatio];
     }];
}

- (void)collectionViewCell:(UICollectionViewCell *)cell didUpdateCellVisibility:(CGFloat)visibilityRatio
{
    if ( visibilityRatio >= 1.0f )
    {
        if ([cell conformsToProtocol:@protocol(VStreamCellTracking)])
        {
            VSequence *sequenceToTrack = [(id<VStreamCellTracking>)cell sequenceToTrack];
            if (sequenceToTrack != nil)
            {
                StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:sequenceToTrack
                                                                                  stream:self.shelf
                                                                               fromShelf:YES];
                [self.streamTrackingHelper onStreamCellDidBecomeVisibleWithCellEvent:event];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.marqueeItems.count;
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
    self.selectedItem = self.marqueeItems[indexPath.row];
    [self.selectionDelegate marqueeController:self
                                didSelectItem:self.marqueeItems[indexPath.row]
                             withPreviewImage:nil
                           fromCollectionView:collectionView
                                  atIndexPath:indexPath];
    
    [self.autoScrollTimerManager invalidate];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.marqueeItems objectAtIndex:indexPath.row];
    VAbstractMarqueeStreamItemCell *cell;
    Class marqueeStreamItemCellClass = [[self class] marqueeStreamItemCellClass];
    NSAssert([marqueeStreamItemCellClass isSubclassOfClass:[VAbstractMarqueeStreamItemCell class]], @"Class returned from marqueeStreamItemCellClass must be a subclass of VAbstractMarqueeStreamItemCell");

    NSString *reuseIdentifierForSequence = [marqueeStreamItemCellClass reuseIdentifierForStreamItem:item baseIdentifier:nil dependencyManager:self.dependencyManager];
    
    if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
    {
        [collectionView registerClass:marqueeStreamItemCellClass
           forCellWithReuseIdentifier:reuseIdentifierForSequence];
        [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
    }
    
    StreamCellContext *context = [[StreamCellContext alloc] initWithStreamItem:item stream:self.currentStream fromShelf:YES];
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[marqueeStreamItemCellClass reuseIdentifierForStreamItem:item baseIdentifier:nil dependencyManager:self.dependencyManager] forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.context = context;
    [cell setupWithStreamItem:item fromStreamWithStreamID:self.currentStream.remoteId];
    
    // Add highlight view
    [self.dependencyManager addHighlightViewToHost:cell];
    
    // Tracking code removed
    
    return cell;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    [self.registeredReuseIdentifiers removeAllObjects];
    NSArray *marqueeItems = self.marqueeItems;
    [self registerStreamItemCellsWithCollectionView:collectionView forMarqueeItems:marqueeItems];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).sectionInset = UIEdgeInsetsZero;
    [self reset];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    for ( VAbstractMarqueeStreamItemCell *marqueeItemCell in self.collectionView.visibleCells )
    {
        marqueeItemCell.dependencyManager = dependencyManager;
    }
}

- (void)registerStreamItemCellsWithCollectionView:(UICollectionView *)collectionView forMarqueeItems:(NSArray *)marqueeItems
{
    if ( collectionView == nil || marqueeItems == nil )
    {
        return;
    }
    
    Class marqueeStreamItemCellClass = [[self class] marqueeStreamItemCellClass];
    NSAssert([marqueeStreamItemCellClass isSubclassOfClass:[VAbstractMarqueeStreamItemCell class]], @"Class returned from marqueeStreamItemCellClass must be a subclass of VAbstractMarqueeStreamItemCell");
    for (VStreamItem *marqueeItem in marqueeItems)
    {
        NSString *reuseIdentifierForSequence = [marqueeStreamItemCellClass reuseIdentifierForStreamItem:marqueeItem
                                                                                         baseIdentifier:nil
                                                                                      dependencyManager:self.dependencyManager];
        
        if (![self.registeredReuseIdentifiers containsObject:reuseIdentifierForSequence])
        {
            UINib *nib = [marqueeStreamItemCellClass nibForCell];
            [collectionView registerNib:nib
             forCellWithReuseIdentifier:reuseIdentifierForSequence];
            [self.registeredReuseIdentifiers addObject:reuseIdentifierForSequence];
        }
    }
}

- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView
{
    NSAssert(false, @"registerCollectionViewCellWithCollectionView: must be implemented by subclasses of VAbstractMarqueeController");
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(false, @"marqueeCellForCollectionView:atIndexPath: must be implemented by subclasses of VAbstractMarqueeController");
    return nil;
}

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"Subclasses must override desiredSizeWithCollectionViewBounds: in VAbstractMarqueeController");
    return CGSizeZero;
}

+ (Class)marqueeStreamItemCellClass
{
    NSAssert(false, @"Subclasses must override marqueeStreamItemCellClass in VAbstractMarqueeController");
    return [VAbstractMarqueeStreamItemCell class];
}

@end
