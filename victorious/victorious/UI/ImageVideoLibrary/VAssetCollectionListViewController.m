//
//  VAssetCollectionListViewController.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionListViewController.h"

// Permissions
#import "VPermissionPhotoLibrary.h"

#import "VAssetGroupTableViewCell.h"

@import Photos;

static NSString * const kAlbumCellReuseIdentifier = @"albumCell";

@interface VAssetCollectionListViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermissions;
@property (nonatomic, assign) BOOL needsFetch;

@property (nonatomic, strong) NSMutableSet *fetchResults;
@property (nonatomic, strong) NSArray *collections;
@property (nonatomic, strong) NSArray *assetFetchResultForCollections;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation VAssetCollectionListViewController

#pragma mark - Lifecycle

+ (instancetype)assetCollectionListViewController
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                 bundle:bundleForClass];
    return [storyboardForClass instantiateInitialViewController];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)awakeFromNib
{
    self.fetchResults = [[NSMutableSet alloc] init];
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.locale = [NSLocale currentLocale];
    self.numberFormatter.groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];

    self.libraryPermissions = [[VPermissionPhotoLibrary alloc] init];
    
    // Fetch once on awakeFromNib
    if ([self.libraryPermissions permissionState] == VPermissionStateAuthorized)
    {
        self.needsFetch = NO;
        [self fetchCollectionsWithCompletion:^
         {
             [self.tableView reloadData];
         }];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (([self.libraryPermissions permissionState] == VPermissionStateAuthorized) && self.needsFetch)
    {
        self.needsFetch = NO;
        [self fetchCollectionsWithCompletion:^
         {
             [self.tableView reloadData];
         }];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.libraryPermissions permissionState] == VPermissionStateAuthorized)
    {
        return self.collections.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VAssetGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuseIdentifier
                                                            forIndexPath:indexPath];
    // Set the localized title on the cell
    PHAssetCollection *collection = self.collections[indexPath.row];
    cell.groupTitleLabel.text = collection.localizedTitle;

    PHFetchResult *fetchResultForCollection = self.assetFetchResultForCollections[indexPath.row];
    [self.fetchResults addObject:fetchResultForCollection];
    
    // Set the count on the subtitle label
    cell.groupSubtitleLabel.text = [self.numberFormatter stringFromNumber:@(fetchResultForCollection.count)];
    
    // Use the first asset as a thumbnail
    PHAsset *firstAsset = [fetchResultForCollection firstObject];
    [[PHImageManager defaultManager] requestImageForAsset:firstAsset
                                               targetSize:CGSizeMake(40, 40)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         cell.groupImageView.image = result;
     }];

    return cell;
}

#pragma mark - Table View Delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForSelectedRows containsObject:indexPath])
    {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *collectionForIndexPath = self.collections[indexPath.row];
    
    if (self.collectionSelectionHandler != nil)
    {
        self.collectionSelectionHandler(collectionForIndexPath);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        VLog(@"Library changed!!!");
        BOOL dirty = NO;
        for (PHFetchResult *fetchResult in self.fetchResults)
        {
            if ([changeInstance changeDetailsForFetchResult:fetchResult])
            {
                dirty = YES;
                break;
            }
        }
        
        if (dirty)
        {
            [self fetchCollectionsWithCompletion:^
             {
                 //TODO: Animate change result
                 [self.tableView reloadData];
             }];
        }
    });
}

#pragma mark - Private Methods

// Completion is called on main Queue
- (void)fetchCollectionsWithCompletion:(void(^)())success
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        // Fetch all albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                              subtype:PHAssetCollectionSubtypeAny
                                                                              options:nil];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                             subtype:PHAssetCollectionSubtypeAny
                                                                             options:nil];
        [self.fetchResults addObject:smartAlbums];
        [self.fetchResults addObject:userAlbums];
        
        // Configure fetch options for media type and creation date
        PHAssetMediaType mediaType = PHAssetMediaTypeImage;
        PHFetchOptions *assetFetchOptions = [[PHFetchOptions alloc] init];
        assetFetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", mediaType];
        assetFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        // We're going to add apropirate collecitons and fetch requests to these arrays
        NSMutableArray *assetCollections = [[NSMutableArray alloc] init];
        NSMutableArray *assetCollectionsFetchResutls = [[NSMutableArray alloc] init];
        
        // Add collections and fetch requests to array if collection contains at least 1 asset of media type
        for (PHAssetCollection *collection in smartAlbums)
        {
            PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                                 options:assetFetchOptions];
            [self.fetchResults addObject:albumMediaTypeResults];
            if (albumMediaTypeResults.count > 0)
            {
                [assetCollections addObject:collection];
                [assetCollectionsFetchResutls addObject:albumMediaTypeResults];
            }
        }
        for (PHAssetCollection *collection in userAlbums)
        {
            PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                                 options:assetFetchOptions];
            [self.fetchResults addObject:albumMediaTypeResults];
            if (albumMediaTypeResults.count > 0)
            {
                [assetCollections addObject:collection];
                [assetCollectionsFetchResutls addObject:albumMediaTypeResults];
            }
        }
        
        self.collections = assetCollections;
        self.assetFetchResultForCollections = assetCollectionsFetchResutls;
        
        dispatch_async(dispatch_get_main_queue(), success);
    });
}

@end
