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
#import "VNavigationHeaderView.h"
#import "UIViewController+VSideMenuViewController.h"
#import "MBProgressHUD.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"

static NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";

static CGFloat const kVDirectoryCellInsetRatio = .03125;//Ratio from spec file.  20 pixels on 640 width.

@interface VDirectoryViewController () <UICollectionViewDelegate, VNavigationHeaderDelegate, VStreamCollectionDataDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic, readwrite) VStreamCollectionViewDataSource *directoryDataSource;
@property (nonatomic, strong) VStream *stream;

@property (nonatomic, strong) VNavigationHeaderView *navHeaderView;
@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end


@implementation VDirectoryViewController

+ (instancetype)streamDirectoryForStream:(VStream *)stream
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VDirectoryViewController *streamDirectory = (VDirectoryViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamDirectoryStoryboardId];
    
    streamDirectory.stream = stream;
    
    return streamDirectory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count == 1)
    {
        self.navHeaderView = [VNavigationHeaderView menuButtonNavHeaderWithControlTitles:nil];
    }
    else
    {
        self.navHeaderView = [VNavigationHeaderView backButtonNavHeaderWithControlTitles:nil];
    }
    
    self.navHeaderView.delegate = self;
    
    [self.view addSubview:self.navHeaderView];
    
    self.headerYConstraint = [NSLayoutConstraint constraintWithItem:self.navHeaderView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0f
                                                                          constant:0.0f];
    
    NSLayoutConstraint *collectionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.navHeaderView
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0f
                                                                          constant:0.0f];
    
    [self.view addConstraints:@[collectionViewTopConstraint, self.headerYConstraint]];
    
    self.directoryDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.stream];
    self.directoryDataSource.delegate = self;
    self.directoryDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.directoryDataSource;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    //Register cells
    UINib *nib = [UINib nibWithNibName:VDirectoryItemCellNameStream bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VDirectoryItemCellNameStream];

    CGFloat sideInset = CGRectGetWidth(self.view.bounds) * kVDirectoryCellInsetRatio;
    self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top, sideInset, 0, sideInset);
    
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navHeaderView.showAddButton = NO;
    self.navHeaderView.headerText = self.stream.name;//Set the title in case there is no logo
    [self.navHeaderView updateUI];
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setStream:(VStream *)stream
{
    _stream = stream;
    if ([self isViewLoaded])
    {
        self.directoryDataSource.stream = stream;
        self.collectionView.dataSource = self.directoryDataSource;
    }
}

#pragma mark - Header

- (void)hideHeader
{
    if (!CGRectContainsRect(self.view.frame, self.navHeaderView.frame))
    {
        return;
    }
    
    self.headerYConstraint.constant = -self.navHeaderView.frame.size.height;
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showHeader
{
    if (CGRectContainsRect(self.view.frame, self.navHeaderView.frame))
    {
        return;
    }
    
    self.headerYConstraint.constant = 0;
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    if (navHeaderView == self.navHeaderView)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)menuPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    if (navHeaderView == self.navHeaderView)
    {
        [self.sideMenuViewController presentMenuViewController];
    }
}

#pragma mark - Refresh

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshWithCompletion:nil];
}

- (void)refreshWithCompletion:(void(^)(void))completionBlock
{
    [self.directoryDataSource refreshWithSuccess:^(void)
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
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
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
    [self.directoryDataSource loadNextPageWithSuccess:^(void)
     {
     }
                                          failure:^(NSError *error)
     {
     }];
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VDirectoryItemCell desiredSizeWithCollectionViewBounds:self.view.bounds];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.directoryDataSource itemAtIndexPath:indexPath];
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

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VDirectoryItemCell *cell;

    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VDirectoryItemCellNameStream forIndexPath:indexPath];
    cell.streamItem = item;
    
    return cell;

}

@end
