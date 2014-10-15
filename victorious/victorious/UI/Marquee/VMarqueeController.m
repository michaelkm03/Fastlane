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

#import "VDirectoryViewController.h"
#import "VContentViewController.h"
#import "VMarqueeTabIndicatorView.h"

#import "VThemeManager.h"

@interface VMarqueeController () <VStreamCollectionDataDelegate>

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;

@property (nonatomic, strong) VStream *stream;
@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;
@property (nonatomic, strong) VStreamItem *currentStreamItem;

@property (nonatomic, strong) NSTimer *autoScrollTimer;

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
        self.stream = stream;
        self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:stream];
        self.streamDataSource.delegate = self;
        self.streamDataSource.collectionView = self.collectionView;
        self.collectionView.dataSource = self.streamDataSource;
    }
    return self;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    self.streamDataSource.collectionView = _collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self.streamDataSource;
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
    if ((unsigned)currentPage == self.tabView.currentlySelectedTab)
    {
        return;
    }
    
    self.tabView.currentlySelectedTab = currentPage;
    self.currentStreamItem = [self.streamDataSource itemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0]];
    [self enableTimer];
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    [self.streamDataSource refreshWithSuccess:
     ^{
         [self.delegate marqueeRefreshedContent:self];
         
         if (successBlock)
         {
             successBlock();
         }
     }
                                      failure:failureBlock];
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
    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
    [self.delegate marquee:self selectedItem:item atIndexPath:indexPath];
    [self.autoScrollTimer invalidate];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    if (currentPage < self.streamDataSource.count)
    {
        [self scrolledToPage:currentPage];
    }
}

- (void)disableTimer
{
    [self.autoScrollTimer invalidate];
}

- (void)enableTimer
{
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                            target:self
                                                          selector:@selector(selectNextTab)
                                                          userInfo:nil
                                                           repeats:NO];
}

#pragma mark - VMarqueeCellDelegate

- (void)cell:(VMarqueeStreamItemCell *)cell selectedUser:(VUser *)user
{
    [self.delegate marquee:self selectedUser:user atIndexPath:[self.collectionView indexPathForCell:cell]];
    [self.autoScrollTimer invalidate];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VMarqueeStreamItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VMarqueeStreamItemCell suggestedReuseIdentifier] forIndexPath:indexPath];
    CGSize size = [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
    cell.bounds = CGRectMake(0, 0, size.width, size.height);
    cell.streamItem = item;
    
    return cell;
}

@end
