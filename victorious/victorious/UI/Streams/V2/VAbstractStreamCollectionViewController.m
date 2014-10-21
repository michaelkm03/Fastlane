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

#import "VNavigationHeaderView.h"
#import "MBProgressHUD.h"

#import "UIActionSheet+VBlocks.h"
#import "VObjectManager+Login.h"

//View Controllers
#import "VStreamContainerViewController.h"
#import "VStreamTableViewController.h"
#import "VContentViewController.h"
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

#import "UIViewController+VNavMenu.h"

const CGFloat kVLoadNextPagePoint = .75f;

@interface VAbstractStreamCollectionViewController () <UICollectionViewDelegate, VNavigationHeaderDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;

@end

@implementation VAbstractStreamCollectionViewController

- (void)dealloc
{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
//    
//    if (self.hasAddAction)
//    {
//        UIImage *image = isTemplateC ? [UIImage imageNamed:@"createContentButtonC"] : [UIImage imageNamed:@"createContentButton"];
//        [self.navHeaderView setRightButtonImage:image
//                                     withAction:@selector(createButtonAction:)
//                                       onTarget:self];
//    }
//    else if (self.hasFindFriendsAction)
//    {
//        [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"findFriendsIcon"]
//                                     withAction:@selector(findFriendsAction:)
//                                       onTarget:self];
//    }
//    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.top = CGRectGetHeight(self.navHeaderView.bounds);

    self.collectionView.contentInset = insets;
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

- (IBAction)createButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:
                                  NSLocalizedString(@"Create a Video Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewController]];
                                  },
                                  NSLocalizedString(@"Create an Image Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewControllerStartingWithStillCapture]];
                                  },
                                  NSLocalizedString(@"Create a Poll", @""), ^(void)
                                  {
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)presentCameraViewController:(VCameraViewController *)cameraViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    UINavigationController *__weak weakNav = navigationController;
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (!finished || !capturedMediaURL)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.previewImage = previewImage;
            publishViewController.mediaURL = capturedMediaURL;
            publishViewController.completion = ^(BOOL complete)
            {
                if (complete)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [weakNav popViewControllerAnimated:YES];
                }
            };
            [weakNav pushViewController:publishViewController animated:YES];
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
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
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    if (translation.y < 0 && scrollView.contentOffset.y > CGRectGetHeight(self.navHeaderView.frame))
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self showHeader];
         }];
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
