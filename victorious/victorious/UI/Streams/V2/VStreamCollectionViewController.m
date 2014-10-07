//
//  VStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

#import "VStreamCollectionViewDataSource.h"
#import "VStreamCollectionCell.h"

//View Controllers
#import "VCommentsContainerViewController.h"

//Views
#import "VNavigationHeaderView.h"

//Data models
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"

//Categories
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

#import "VConstants.h"

static NSString * const kStreamCollectionStoryboardId = @"kStreamCollection";

@interface VStreamCollectionViewController () <VNavigationHeaderDelegate>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;

@property (strong, nonatomic) NSString *headerTitle;

@end

@implementation VStreamCollectionViewController

+ (instancetype)homeStreamCollection
{
    VStream *recentStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *hotStream = [VStream hotSteamForSteamName:@"home"];
    VStream *followingStream = [VStream followerStreamForStreamName:@"home" user:nil];
    
    VStreamCollectionViewController *homeStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream, followingStream]];
    homeStream.headerTitle = NSLocalizedString(@"Home", nil);
    return homeStream;
}

+ (instancetype)streamViewControllerForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamCollectionViewController *streamColllection = (VStreamCollectionViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamCollectionStoryboardId];
    
    streamColllection.currentStream = stream;
    streamColllection.allStreams = allStreams;
    
    return streamColllection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UINib *nib = [UINib nibWithNibName:VStreamCollectionCellName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VStreamCollectionCellName];
    
    NSInteger selectedStream = [self.allStreams indexOfObject:self.currentStream];
    [self.navHeaderView.segmentedControl setSelectedSegmentIndex:selectedStream];
    self.navHeaderView.headerText = self.headerTitle ?: self.currentStream.name;
    
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navHeaderView updateUI];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    VStreamCollectionCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VStreamCollectionCellName forIndexPath:indexPath];
    cell.sequence = (VSequence *)item;
    
    return cell;
}

#pragma mark - VNavigationHeaderDelegate

- (BOOL)navHeaderView:(VNavigationHeaderView *)navHeaderView segmentControlChangeToIndex:(NSInteger)index
{
    if (self.allStreams.count <= (NSUInteger)index)
    {
        return NO;
    }
    
    self.currentStream = self.allStreams[index];
    
    if (!self.currentStream.streamItems.count)
    {
        [self refresh:self.refreshControl];
    }
    
    return YES;
}

#pragma mark - Actions

- (void)setBackgroundImageWithURL:(NSURL *)url
{
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.collectionView.backgroundView.frame];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [newBackgroundView setBlurredImageWithURL:url
                             placeholderImage:placeholderImage
                                    tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.collectionView.backgroundView = newBackgroundView;
}

//#pragma mark - Notifications
//
//- (void)dataSourceDidChange:(NSNotification *)notification
//{
//    self.hasRefreshed = YES;
//    [self updateNoContentViewAnimated:YES];
//}

#pragma mark - VStreamViewCellDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject inStreamCollectionCell:(VStreamCollectionCell *)streamCollectionCell
{
    VStreamCollectionCell *cell = streamCollectionCell;
    
    self.lastSelectedIndexPath = [self.collectionView indexPathForCell:cell];
    
    [self setBackgroundImageWithURL:[[sequenceObject initialImageURLs] firstObject]];
    //TODO: probly need to hide this
//    [self.delegate streamWillDisappear];
    
    VCommentsContainerViewController *commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = sequenceObject;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

@end
