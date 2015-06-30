//
//  VAssetCollectionListViewController.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionListViewController.h"

@import Photos;

static NSString * const kAlbumCellReuseIdentifier = @"albumCell";

@interface VAssetCollectionListViewController ()

@property (strong) NSArray *collectionsFetchResults;

@end

@implementation VAssetCollectionListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
//    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
//    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:NO]];

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:fetchOptions];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny
                                                                         options:fetchOptions];
    
//    PHFetchResult *topLevelCollections = [PHCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
    self.collectionsFetchResults = @[smartAlbums, userAlbums];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collectionsFetchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PHFetchResult *fetchResultForSection = self.collectionsFetchResults[section];
    return fetchResultForSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuseIdentifier
                                                            forIndexPath:indexPath];
    
    // Configure cell
    PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section];
    PHAssetCollection *collection = fetchResult[indexPath.row];
    cell.textLabel.text = collection.localizedTitle;
    
    PHFetchResult *itemsInCollection = [PHAsset fetchAssetsInAssetCollection:collection
                                                                     options:nil];
    PHAsset *firstAsset = [itemsInCollection firstObject];
    
    [[PHImageManager defaultManager] requestImageForAsset:firstAsset
                                               targetSize:CGSizeMake(44, 44)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         cell.imageView.image = result;
         [cell layoutIfNeeded];
     }];
    
    return cell;
}

@end
