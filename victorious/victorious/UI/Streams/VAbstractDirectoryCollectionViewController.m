//
//  VAbstractDirectoryCollectionViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractDirectoryCollectionViewController.h"
#import "VDependencyManager+VObjectManager.h"
#import "VStream+Fetcher.h"
#import "NSString+VParseHelp.h"
#import "VObjectManager.h"
#import "VAbstractMarqueeController.h"
#import "VUserProfileViewController.h"

static NSString * const kStreamURLKey = @"streamURL";
static NSString * const kMarqueeKey = @"marqueeCell";

@interface VAbstractDirectoryCollectionViewController () <VMarqueeSelectionDelegate, VMarqueeDataDelegate>

@property (nonatomic, readwrite) UICollectionView *collectionView;

@end

@implementation VAbstractDirectoryCollectionViewController

@synthesize collectionView;

#pragma mark - Initializers

+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager
{
    VAbstractDirectoryCollectionViewController *streamDirectory = [[[self class] alloc] initWithNibName:nil
                                                                                                                       bundle:nil];
    streamDirectory.currentStream = stream;
    streamDirectory.title = stream.name;
    streamDirectory.dependencyManager = dependencyManager;
    streamDirectory.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    streamDirectory.marqueeController = [dependencyManager templateValueOfType:[VAbstractMarqueeController class] forKey:kMarqueeKey];
    [streamDirectory.marqueeController registerCellsWithCollectionView:streamDirectory.collectionView];
    streamDirectory.marqueeController.selectionDelegate = streamDirectory;
    streamDirectory.marqueeController.dataDelegate = streamDirectory;
    
    return streamDirectory;
}

#pragma mark - VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    VStream *stream = [VStream streamForPath:[[dependencyManager stringForKey:kStreamURLKey] v_pathComponent] inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    return [self streamDirectoryForStream:stream dependencyManager:dependencyManager];
}

#pragma mark - Shared setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateHeaderCellVisibility];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    NSDictionary *views = @{ @"collectionView" : self.collectionView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    NSString *identifier = [self cellIdentifier];
    UINib *nib = [self cellNib];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.streamDataSource;
    self.collectionView.delegate = self;
    
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Layout may have changed between awaking from nib and being added to the container of the SoS
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)canShowMarquee
{
    return YES;
}

- (void)updateHeaderCellVisibility
{
    if ( [self canShowMarquee] )
    {
        self.streamDataSource.hasHeaderCell = self.marqueeController.stream.marqueeItems.count > 0;
    }
}

#pragma mark - VMarqueeControllerDataDelegate

- (void)marquee:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems
{
    [self updateHeaderCellVisibility];
}

#pragma mark - VMarqueeControllerSelectionDelegate

- (void)marquee:(VAbstractMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image
{
    NSDictionary *params = @{ VTrackingKeyName : streamItem.name ?: @"",
                              VTrackingKeyRemoteId : streamItem.remoteId ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromMarquee parameters:params];
    
    [self navigateToDisplayStreamItem:streamItem];
}

- (void)marquee:(VAbstractMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path
{
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ( section == 0 )
    {
        return UIEdgeInsetsMake(self.topInset,
                                0,
                                0,
                                0);
    }
    return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem = [self.streamDataSource itemAtIndexPath:indexPath];
    [self navigateToDisplayStreamItem:streamItem];
}

- (BOOL)isMarqueeSection:(NSUInteger)section
{
    return ( self.streamDataSource.hasHeaderCell && section == 0 );
}

- (CGSize)marqueeSizeWithCollectionViewBounds:(CGRect)collectionViewBounds
{
    return [self.marqueeController desiredSizeWithCollectionViewBounds:collectionViewBounds];
}

#pragma mark - Functions that must be overridden

- (NSString *)cellIdentifier
{
    NSAssert(false, @"cellIdentifier must be overridden by subclasses");
    return nil;
}

- (UINib *)cellNib
{
    NSAssert(false, @"cellNib must be overridden by subclasses");
    return nil;
}

- (void)navigateToDisplayStreamItem:(VStreamItem *)streamItem
{
    NSAssert(false, @"NavigateToDisplayStreamItem must be overridden by subclasses");
}

@end
