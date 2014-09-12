//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryCollectionViewController.h"

#import "VDirectoryDataSource.h"
#import "VDirectoryItemCell.h"

#import "VStreamTableViewController.h"
#import "VContentViewController.h"

//Data Models
#import "VDirectory.h"
#import "VSequence.h"

#warning test imports
#import "VObjectManager.h"
#import "VStream+Fetcher.h"
#import "VConstants.h"


NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";

@interface VDirectoryCollectionViewController () <UICollectionViewDelegate>

@property (strong, nonatomic, readwrite) VDirectoryDataSource* directoryDataSource;
@property (nonatomic, strong) VDirectory* directory;

@end


@implementation VDirectoryCollectionViewController

+ (instancetype)streamDirectoryForDirectory:(VDirectory*)directory
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VDirectoryCollectionViewController *streamDirectory = (VDirectoryCollectionViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamDirectoryStoryboardId];
    
#warning test code
    VDirectory *aDirectory = [NSEntityDescription insertNewObjectForEntityForName:@"Directory" inManagedObjectContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    aDirectory.name = @"test";
    VStream *homeStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *communityStream = [VStream streamForCategories: VUGCCategories()];
    VStream *ownerStream = [VStream streamForCategories: VOwnerCategories()];
    homeStream.name = @"Home";
    homeStream.previewImage = @"http://victorious.com/img/logo.png";
    [homeStream addDirectoriesObject:aDirectory];
    
    communityStream.name = @"Community";
    communityStream.previewImage = @"https://www.google.com/images/srpr/logo11w.png";
    [communityStream addDirectoriesObject:aDirectory];
    
    ownerStream.name = @"Owner";
    ownerStream.previewImage = @"https://www.google.com/images/srpr/logo11w.png";
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
    
    self.directoryDataSource = [[VDirectoryDataSource alloc] initWithDirectory:self.directory];
    self.collectionView.dataSource = self.directoryDataSource;
    
    //Register cells
    UINib *nib = [UINib nibWithNibName:kVStreamDirectoryItemCellName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kVStreamDirectoryItemCellName];
}

- (void)setDirectory:(VDirectory *)directory
{
    _directory = directory;
    if ([self isViewLoaded])
    {
        self.directoryDataSource.directory = directory;
    }
}

#pragma mark - CollectionViewDelegate
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
        VDirectoryCollectionViewController *directoryVC = [VDirectoryCollectionViewController streamDirectoryForDirectory:(VDirectory*)item];
        [self.navigationController pushViewController:directoryVC animated:YES];
    }
}

@end
