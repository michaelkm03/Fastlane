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

#import "VThemeManager.h"

@interface VMarqueeViewController () <UICollectionViewDelegate, UIScrollViewDelegate, VStreamCollectionDataDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VStream *stream;
@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;
@property (nonatomic, strong) VStreamItem *currentStreamItem;

@end

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
    self.collectionView.contentInset = UIEdgeInsetsZero;
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:_stream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.streamDataSource;
    
    [self.streamDataSource refreshWithSuccess:^(void)
    {
        [self.collectionView reloadData];
    }
                                      failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:self.view.bounds];
}

//Let the container handle the selection.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    self.currentStreamItem = [self.streamDataSource itemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0]];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VMarqueeStreamItemCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VMarqueeStreamItemCell suggestedReuseIdentifier] forIndexPath:indexPath];
    cell.streamItem = item;
    cell.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    return cell;
}

@end
