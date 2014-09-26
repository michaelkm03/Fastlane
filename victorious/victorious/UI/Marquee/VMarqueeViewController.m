//
//  VMarqueeViewController.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeViewController.h"

#import "VStream+Fetcher.h"
#import "VSequence.h"

#import "VStreamCollectionViewDataSource.h"
#import "VMarqueeStreamItemCell.h"

#import "VDirectoryViewController.h"
#import "VContentViewController.h"
#import "VMarqueeTabIndicatorView.h"

#import "VThemeManager.h"

@interface VMarqueeViewController () <UICollectionViewDelegate, UIScrollViewDelegate, VStreamCollectionDataDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *tabContainerView;

@property (nonatomic, strong) VMarqueeTabIndicatorView *tabView;

@property (nonatomic, strong) VStream *stream;
@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;
@property (nonatomic, strong) VStreamItem *currentStreamItem;

@property (nonatomic, strong) NSTimer *autoScrollTimer;

@end

static CGFloat const kVTabSpacingRatio = 0.0390625;//From spec file, 25/640

@implementation VMarqueeViewController

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self)
    {
        // Custom initialization
        self.stream = [VStream streamForMarquee];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerNib:[VMarqueeStreamItemCell nibForCell] forCellWithReuseIdentifier:[VMarqueeStreamItemCell suggestedReuseIdentifier]];
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:_stream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.streamDataSource;
    
    self.tabView = [[VMarqueeTabIndicatorView alloc] initWithFrame:self.tabContainerView.frame];
    self.tabView.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.tabView.deselectedColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor] colorWithAlphaComponent:.3f];
    self.tabView.spacingBetweenTabs = CGRectGetWidth(self.view.bounds) * kVTabSpacingRatio;
    self.tabView.tabImage = [UIImage imageNamed:@"tabIndicator"];
    [self.view addSubview:self.tabView];
    
    [self.streamDataSource refreshWithSuccess:^(void)
    {
        self.tabView.currentlySelectedTab = 0;
        self.tabView.numberOfTabs = self.streamDataSource.count;
        [self scheduleAutoScrollTimer];
        
        [self.collectionView reloadData];
    }
                                      failure:nil];
}

- (void)scheduleAutoScrollTimer
{
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                            target:self
                                                          selector:@selector(selectNextTab)
                                                          userInfo:nil
                                                           repeats:NO];
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
    [self scheduleAutoScrollTimer];
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:self.view.bounds];
}

//Let the container handle the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UINavigationController *navController = [self.delegate navigationControllerForMarquee:self];
//    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
//    UIViewController *viewControllerToPush;
//    if ([item isKindOfClass:[VStream class]])
//    {
//        
//    }
//    else if ([item isKindOfClass:[VSequence class]])
//    {
//
//    }
//    if (viewControllerToPush)
//    {
//        [navController pushViewController:viewControllerToPush animated:YES];
//    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    [self scrolledToPage:currentPage];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.autoScrollTimer invalidate];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self.autoScrollTimer invalidate];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self scheduleAutoScrollTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self scheduleAutoScrollTimer];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VMarqueeStreamItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VMarqueeStreamItemCell suggestedReuseIdentifier] forIndexPath:indexPath];
    CGSize size = [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:self.view.bounds];
    cell.bounds = CGRectMake(0, 0, size.width, size.height);
    cell.streamItem = item;
    cell.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    
    return cell;
}

@end
