//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryViewController.h"

#import "VStreamCollectionViewDataSource.h"
#import "VDirectoryItemCell.h"

#import "VStreamContainerViewController.h"
#import "VStreamTableViewController.h"
#import "VContentViewController.h"
#import "VNavigationHeaderView.h"
#import "UIViewController+VSideMenuViewController.h"
#import "MBProgressHUD.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"

static NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";

static CGFloat const kVDirectoryCellInsetRatio = .03125;//Ratio from spec file.  20 pixels on 640 width.

@interface VDirectoryViewController () <UICollectionViewDelegate, VNavigationHeaderDelegate, VStreamCollectionDataDelegate>

@end


@implementation VDirectoryViewController

+ (instancetype)streamDirectoryForStream:(VStream *)stream
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VDirectoryViewController *streamDirectory = (VDirectoryViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamDirectoryStoryboardId];
    
    streamDirectory.currentStream = stream;
    
    return streamDirectory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    //Register cells
    UINib *nib = [UINib nibWithNibName:VDirectoryItemCellNameStream bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VDirectoryItemCellNameStream];

    CGFloat sideInset = CGRectGetWidth(self.view.bounds) * kVDirectoryCellInsetRatio;
    self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top, sideInset, 0, sideInset);
    
    [self refresh:self.refreshControl];
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VDirectoryItemCell desiredSizeWithCollectionViewBounds:self.view.bounds];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
    //Commented out code is the inital logic for supporting other stream types / sequences in streams.
    if ([item isKindOfClass:[VStream class]])// && [((VStream *)item) onlyContainsSequences])
    {
        NSString *streamName = [@"stream" stringByAppendingString: item.remoteId];
        VStreamTableViewController *streamTable = [VStreamTableViewController streamWithDefaultStream:(VStream *)item
                                                                                                 name:streamName
                                                                                                title:item.name];
        VStreamContainerViewController *streamContainer = [VStreamContainerViewController modalContainerForStreamTable:streamTable];
        [self.navigationController pushViewController:streamContainer animated:YES];
    }
//    else if ([item isKindOfClass:[VStream class]])
//    {
//        VDirectoryViewController *sos = [VDirectoryViewController streamDirectoryForStream:(VStream *)item];
//        [self.navigationController pushViewController:sos animated:YES];
//    }
//    else if ([item isKindOfClass:[VSequence class]])
//    {
//        VContentViewController *contentViewController = [[VContentViewController alloc] init];
//        contentViewController.sequence = (VSequence *)item;
//        [self.navigationController pushViewController:contentViewController animated:YES];
//    }
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    VDirectoryItemCell *cell;

    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VDirectoryItemCellNameStream forIndexPath:indexPath];
    cell.streamItem = item;
    
    return cell;
}

@end
