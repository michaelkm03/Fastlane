//
//  VBaseMarqueeController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeController.h"
#import "VAbstractMarqueeStreamItemCell.h"
#import "VTimerManager.h"
#import "VStreamItem.h"
#import "VStream.h"

NSString * const kMarqueeURLKey = @"marqueeURL";

@interface VAbstractMarqueeController () <UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic, readwrite) VTimerManager *autoScrollTimerManager;
@property (nonatomic, readwrite) VStreamItem *currentStreamItem;

@end

@implementation VAbstractMarqueeController

- (instancetype)initWithStream:(VStream *)stream
{
    self = [super init];
    if (self)
    {
        _stream = stream;
        _streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:stream];
        _streamDataSource.delegate = self;
        _streamDataSource.collectionView = _collectionView;
        _collectionView.dataSource = _streamDataSource;
        _currentPage = 0;
    }
    return self;
}

- (NSString *)cellSuggestedReuseIdentifier
{
    return [VAbstractMarqueeStreamItemCell suggestedReuseIdentifier];
}

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"Subclasses must override desiredSizeWithCollectionViewBounds: in VAbstractMarqueeController");
    return CGSizeZero;
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    [self.streamDataSource loadPage:VPageTypeFirst withSuccess:
     ^{
         [self scrolledToPage:0];
         
         [self.delegate marqueeRefreshedContent:self];
         
         if (successBlock)
         {
             successBlock();
         }
     }
                            failure:failureBlock];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    [self enableTimer];
    if ( currentPage != self.currentPage )
    {
        self.currentPage = currentPage;
        if ( (NSUInteger) self.currentPage < self.streamDataSource.count )
        {
            [self scrolledToPage:self.currentPage];
        }
    }
}

- (void)selectNextTab
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    currentPage ++;
    if (currentPage == (NSInteger)self.streamDataSource.count)
    {
        currentPage = 0;
    }
    
    [self.collectionView setContentOffset:CGPointMake(currentPage * pageWidth, self.collectionView.contentOffset.y) animated:YES];
}

- (void)scrolledToPage:(NSInteger)currentPage
{
    self.currentStreamItem = [self.streamDataSource itemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0]];
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
    return 5.0f;
}

#pragma mark - VStreamCollectionDataDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self desiredSizeWithCollectionViewBounds:collectionView.bounds];
}

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VAbstractMarqueeStreamItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[self cellSuggestedReuseIdentifier] forIndexPath:indexPath];
    cell.streamItem = item;
    cell.dependencyManager = self.dependencyManager;
    
    return cell;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    self.streamDataSource.collectionView = _collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self.streamDataSource;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    for ( VAbstractMarqueeStreamItemCell *marqueeItemCell in self.collectionView.visibleCells )
    {
        marqueeItemCell.dependencyManager = dependencyManager;
    }
}

- (void)dealloc
{
    if (_collectionView.delegate == self)
    {
        _collectionView.delegate = nil;
    }
    [_autoScrollTimerManager invalidate];
}

@end
