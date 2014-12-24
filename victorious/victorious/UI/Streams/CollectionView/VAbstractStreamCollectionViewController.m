//
//  VAbstractStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"

#import "VStreamCollectionViewDataSource.h"
#import "VDirectoryItemCell.h"

#import "MBProgressHUD.h"

#import "UIActionSheet+VBlocks.h"
#import "VObjectManager+Login.h"

//View Controllers
#import "VCameraPublishViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VCameraViewController.h"
#import "VCreatePollViewController.h"
#import "VFindFriendsViewController.h"
#import "VAuthorizationViewControllerFactory.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"
#import "VAbstractFilter.h"

#import "VSettingManager.h"

const CGFloat kVLoadNextPagePoint = .75f;

@interface VAbstractStreamCollectionViewController () <UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;

@end

@implementation VAbstractStreamCollectionViewController

- (void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( !self.refreshControl.isRefreshing && self.streamDataSource.count == 0 )
    {
        [self refresh:nil];
    }
    
    [self.refreshControl removeFromSuperview];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    UIView *subView = self.refreshControl.subviews[0];
    
    //Since we're using the collection flow delegate method for the insets, we need to manually position the frame of the refresh control.
    subView.frame = CGRectMake(CGRectGetMinX(subView.frame), CGRectGetMinY(subView.frame) + self.contentInset.top / 2,
                               CGRectGetWidth(subView.frame), CGRectGetHeight(subView.frame));
}

- (void)setCurrentStream:(VStream *)currentStream
{
    _currentStream = currentStream;
    if ([self isViewLoaded])
    {
        self.streamDataSource.stream = currentStream;
        self.collectionView.dataSource = self.streamDataSource;
    }
}

- (IBAction)findFriendsAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    VFindFriendsViewController *ffvc = [VFindFriendsViewController newFindFriendsViewController];
    [ffvc setShouldAutoselectNewFriends:NO];
    [self.navigationController pushViewController:ffvc animated:YES];
}

#pragma mark - Refresh

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshWithCompletion:nil];
}

- (void)refreshWithCompletion:(void(^)(void))completionBlock
{
    if (self.streamDataSource.isFilterLoading)
    {
        return;
    }
    
    [self.streamDataSource refreshWithSuccess:^(void)
     {
         [self.refreshControl endRefreshing];
         if (completionBlock)
         {
             completionBlock();
         }
     }
                                         failure:^(NSError *error)
     {
         [self.refreshControl endRefreshing];
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hud.mode = MBProgressHUDModeText;
         hud.labelText = NSLocalizedString(@"RefreshError", @"");
         hud.userInteractionEnabled = NO;
         [hud hide:YES afterDelay:3.0];
     }];
    
    [self.refreshControl beginRefreshing];
    self.refreshControl.hidden = NO;
}

- (void)loadNextPageAction
{
    if (self.streamDataSource.isFilterLoading)
    {
        return;
    }
    
    [self.streamDataSource loadNextPageWithSuccess:^(void)
     {
     }
                                              failure:^(NSError *error)
     {
     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollThreshold = scrollView.contentSize.height * kVLoadNextPagePoint;
    if (self.streamDataSource.filter.currentPageNumber.intValue < self.streamDataSource.filter.maxPageNumber.intValue &&
        self.streamDataSource.count &&
        ![self.streamDataSource isFilterLoading] &&
        scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollThreshold)
    {
        [self loadNextPageAction];
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
