//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryViewController.h"

#import "VDirectoryDataSource.h"
#import "VDirectoryItemCell.h"

#import "VStreamTableViewController.h"
#import "VContentViewController.h"
#import "VNavigationHeaderView.h"
#import "UIViewController+VSideMenuViewController.h"

//Data Models
#import "VDirectory.h"
#import "VSequence.h"

#warning test imports
#import "VObjectManager.h"
#import "VStream+Fetcher.h"
#import "VConstants.h"

NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";

@interface VDirectoryViewController () <UICollectionViewDelegate, VNavigationHeaderDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic, readwrite) VDirectoryDataSource *directoryDataSource;
@property (nonatomic, strong) VDirectory *directory;

@property (nonatomic, strong) VNavigationHeaderView *navHeaderView;
@property (nonatomic, strong) NSLayoutConstraint *headerYConstraint;

@end


@implementation VDirectoryViewController

+ (instancetype)streamDirectoryForDirectory:(VDirectory *)directory
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VDirectoryViewController *streamDirectory = (VDirectoryViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamDirectoryStoryboardId];
    
#warning test code
    VDirectory *aDirectory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    aDirectory.name = @"test";
    VStream *homeStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *communityStream = [VStream streamForCategories: VUGCCategories()];
    VStream *ownerStream = [VStream streamForCategories: VOwnerCategories()];
    homeStream.name = @"Home";
    homeStream.previewImagesObject = @"http://victorious.com/img/logo.png";
    [homeStream addDirectoriesObject:aDirectory];
    
    communityStream.name = @"Community";
    communityStream.previewImagesObject = @"https://www.google.com/images/srpr/logo11w.png";
    [communityStream addDirectoriesObject:aDirectory];
    
    ownerStream.name = @"Owner";
    ownerStream.previewImagesObject = @"https://www.google.com/images/srpr/logo11w.png";
    [ownerStream addDirectoriesObject:aDirectory];
    
    for (VSequence *sequence in homeStream.sequences)
    {
        [sequence addDirectoriesObject:aDirectory];
    }
    
    streamDirectory.directory = aDirectory;
    
    return streamDirectory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navHeaderView = [VNavigationHeaderView menuButtonNavHeaderWithControlTitles:nil];
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
    
    self.directoryDataSource = [[VDirectoryDataSource alloc] initWithDirectory:self.directory];
    self.collectionView.dataSource = self.directoryDataSource;
    
    //Register cells
    UINib *nib = [UINib nibWithNibName:kVStreamDirectoryItemCellName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kVStreamDirectoryItemCellName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

- (void)setDirectory:(VDirectory *)directory
{
    _directory = directory;
    if ([self isViewLoaded])
    {
        self.directoryDataSource.directory = directory;
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


- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)menuButtonPressed
{
    [self.sideMenuViewController presentMenuViewController];
}

- (void)addButtonPressed
{
    
}

#pragma mark - CollectionViewDelegate

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
    VDirectoryItem *item = [self.directoryDataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[VStream class]])
    {
        VStreamTableViewController *streamTable = [VStreamTableViewController streamWithDefaultStream:(VStream *)item name:item.name title:item.name];
        [self.navigationController pushViewController:streamTable animated:YES];
    }
    else if ([item isKindOfClass:[VSequence class]])
    {
        VContentViewController *contentViewController = [[VContentViewController alloc] init];
        contentViewController.sequence = (VSequence *)item;
        [self.navigationController pushViewController:contentViewController animated:YES];
    }
    else if ([item isKindOfClass:[VDirectory class]])
    {
        VDirectoryViewController *directoryVC = [VDirectoryViewController streamDirectoryForDirectory:(VDirectory*)item];
        [self.navigationController pushViewController:directoryVC animated:YES];
    }
}

@end
