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
#import "VDependencyManager+VHighlightContainer.h"
#import "VStreamTrackingHelper.h"
#import "VStreamCellFocus.h"
#import "VStreamItemPreviewView.h"

static NSString * const kStreamURLKey = @"streamURL";
static NSString * const kSequenceIDKey = @"sequenceID";
static NSString * const kSequenceIDMacro = @"%%SEQUENCE_ID%%";
static const CGFloat kDefaultMarqueeTimerFireDuration = 5.0f;

@interface VAbstractMarqueeController ()

@property (nonatomic, readwrite) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger currentFocusPage;
@property (nonatomic, readwrite) VTimerManager *autoScrollTimerManager;
@property (nonatomic, readwrite) VStreamItem *currentStreamItem;
@property (nonatomic, strong) NSMutableSet *registeredReuseIdentifiers;

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
    [self registerStreamItemCellsWithCollectionView:self.collectionView forMarqueeItems:[self.stream.marqueeItems array]];
    [self.collectionView reloadData];
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
    
    [self updateFocus];
    
    [self updateCellVisibilityTracking];
}

- (void)updateFocus
{
    //Update the focus of preview views that conform to VStreamCellFocus
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentFocusPage = ( self.collectionView.contentOffset.x + pageWidth / 2 ) / pageWidth;
    currentFocusPage = MIN( currentFocusPage, (NSInteger)self.stream.marqueeItems.count - 1 );
    currentFocusPage = MAX( currentFocusPage, 0 );

    if ( (NSUInteger)currentFocusPage != self.currentFocusPage )
    {
        self.currentFocusPage = currentFocusPage;
        VStreamItem *focusedStreamItem = self.stream.marqueeItems[currentFocusPage];
        for ( VAbstractMarqueeStreamItemCell *cell in self.collectionView.visibleCells )
        {
            if ( [cell.previewView conformsToProtocol:@protocol(VStreamCellFocus)] )
            {
                BOOL hasFocus = [focusedStreamItem isEqual:cell.streamItem];
                [(VStreamItemPreviewView <VStreamCellFocus> *)cell.previewView setHasFocus:hasFocus];
            }
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

#pragma mark - Cell visibility

- (void)updateCellVisibilityTracking
{
    if (!self.shouldTrackMarqueeCellViews)
    {
        return;
    }
    
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
                [self.streamTrackingHelper onStreamCellDidBecomeVisibleWithStream:self.stream
                                                                         sequence:sequenceToTrack
                                                                        fromShelf:YES];
            }
        }
    }
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
    
    [self.selectionDelegate marquee:self selectedItem:item atIndexPath:indexPath previewImage:nil];
    [self.autoScrollTimerManager invalidate];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.marqueeItems objectAtIndex:indexPath.row];
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
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[marqueeStreamItemCellClass reuseIdentifierForStreamItem:item baseIdentifier:nil dependencyManager:self.dependencyManager] forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.streamItem = item;
    
    // Add highlight view
    [self.dependencyManager addHighlightViewToHost:cell];
    
    return cell;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    [self registerStreamItemCellsWithCollectionView:collectionView forMarqueeItems:[self.stream.marqueeItems array]];
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

- (void)setupStreamItemCell:(VAbstractMarqueeStreamItemCell *)streamItemCell withDependencyManager:(VDependencyManager *)dependencyManager andStreamItem:(VStreamItem *)streamItem
{
    NSAssert(false, @"Subclasses must override setupStreamItemCell:withDependencyManager:andStreamItem: in VAbstractMarqueeController");
}

+ (Class)marqueeStreamItemCellClass
{
    NSAssert(false, @"Subclasses must override marqueeStreamItemCellClass in VAbstractMarqueeController");
    return [VAbstractMarqueeStreamItemCell class];
}

@end
