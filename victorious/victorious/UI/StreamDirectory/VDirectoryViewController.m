//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryViewController.h"

// Data Source
#import "VStreamCollectionViewDataSource.h"

// ViewControllers
#import "VNewContentViewController.h"
#import "VStreamContainerViewController.h"
#import "VStreamTableViewController.h"

// Menu
#import "UIViewController+VSideMenuViewController.h"

// Views
#import "VNavigationHeaderView.h"
#import "MBProgressHUD.h"
#import "VDirectoryItemCell.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"


@interface VDirectoryViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VNavigationHeaderDelegate, VStreamCollectionDataDelegate, VNewContentViewControllerDelegate>

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
    VDirectoryViewController *streamDirectory = [[VDirectoryViewController alloc] initWithNibName:nil
                                                                                           bundle:nil];
    streamDirectory.stream = stream;
    return streamDirectory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.navigationController.viewControllers.count == 1)
    {
        self.navHeaderView = [VNavigationHeaderView menuButtonNavHeaderWithControlTitles:nil];
    }
    else
    {
        self.navHeaderView = [VNavigationHeaderView backButtonNavHeaderWithControlTitles:nil];
    }
    self.navHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.navHeaderView.delegate = self;
    
    [self.view addSubview:self.navHeaderView];
    
    self.headerYConstraint = [NSLayoutConstraint constraintWithItem:self.navHeaderView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f];

    
    [self.view addConstraints:@[self.headerYConstraint]];
    
    //Register cells
    UINib *nib = [UINib nibWithNibName:VDirectoryItemCellNameStream bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VDirectoryItemCellNameStream];
    
    self.directoryDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.stream];
    self.directoryDataSource.delegate = self;
    self.directoryDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.directoryDataSource;
    self.collectionView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navHeaderView.showAddButton = NO;
    self.navHeaderView.headerText = self.stream.name;//Set the title in case there is no logo
    [self.navHeaderView updateUI];
    
    [self.view layoutIfNeeded];
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Property Accessors

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
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    width = width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing;
    width = floorf(width * 0.5f);
    
    BOOL isStreamOfStreamsRow = [[self.directoryDataSource itemAtIndexPath:indexPath] isKindOfClass:[VStream class]];
    
    if (((indexPath.row % 2) == 1) && !isStreamOfStreamsRow)
    {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        isStreamOfStreamsRow = [[self.directoryDataSource itemAtIndexPath:previousIndexPath] isKindOfClass:[VStream class]];
    }
    
    CGFloat height = isStreamOfStreamsRow ? [VDirectoryItemCell desiredStreamOfStreamsHeight] : [VDirectoryItemCell desiredStreamOfContentHeight];
    
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.directoryDataSource itemAtIndexPath:indexPath];
    //Commented out code is the inital logic for supporting other stream types / sequences in streams.
    if ([item isKindOfClass:[VStream class]] && [((VStream *)item) onlyContainsSequences])
    {
        NSString *streamName = [@"stream" stringByAppendingString: item.remoteId];
        VStreamTableViewController *streamTable = [VStreamTableViewController streamWithDefaultStream:(VStream *)item
                                                                                                 name:streamName
                                                                                                title:item.name];
        VStreamContainerViewController *streamContainer = [VStreamContainerViewController modalContainerForStreamTable:streamTable];
        [self.navigationController pushViewController:streamContainer animated:YES];
    }
    else if ([item isKindOfClass:[VStream class]])
    {
        VDirectoryViewController *sos = [VDirectoryViewController streamDirectoryForStream:(VStream *)item];
        [self.navigationController pushViewController:sos animated:YES];
    }
    else if ([item isKindOfClass:[VSequence class]])
    {
        VContentViewViewModel *contentViewViewModel = [[VContentViewViewModel alloc] initWithSequence:(VSequence *)item];
        VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewViewModel];
        contentViewController.delegate = self;
        [self.navigationController pushViewController:contentViewController animated:YES];
    }
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

#pragma mark - VNewContentViewControllerDelegate

- (void)newContentViewControllerDidClose:(VNewContentViewController *)contentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
    contentViewController.delegate = nil;
}

- (void)newContentViewControllerDidDeleteContent:(VNewContentViewController *)contentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self refresh:self.refreshControl];
    contentViewController.delegate = nil;
}

@end
