//
//  VAssetCollectionListViewController.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionListViewController.h"

#import "VAssetGroupTableViewCell.h"

@import Photos;

static NSString * const kAlbumCellReuseIdentifier = @"albumCell";

@interface VAssetCollectionListViewController ()

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSCache *cachedFetchResultsForCollections;

@end

@implementation VAssetCollectionListViewController

+ (instancetype)assetCollectionListViewController
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                 bundle:bundleForClass];
    return [storyboardForClass instantiateInitialViewController];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cachedFetchResultsForCollections = [[NSCache alloc] init];
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.locale = [NSLocale currentLocale];
    self.numberFormatter.groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
}

#pragma mark - Property Accessors

- (void)setAssetCollections:(NSArray *)assetCollections
{
    _assetCollections = assetCollections;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VAssetGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuseIdentifier
                                                            forIndexPath:indexPath];
    // Set the localized title on the cell
    PHAssetCollection *collection = self.assetCollections[indexPath.row];
    cell.groupTitleLabel.text = collection.localizedTitle;

    // Fetch the items in the collection
    PHFetchResult *itemsInCollection = [self fetchResultForAssetsInCollection:collection];
    
    // Set the count on the subtitle label
    cell.groupSubtitleLabel.text = [self.numberFormatter stringFromNumber:@(itemsInCollection.count)];
    
    // Use the first asset as a thumbnail
    PHAsset *firstAsset = [itemsInCollection firstObject];
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
    PHAssetCollection *collectionForIndexPath = self.assetCollections[indexPath.row];
    
    if (self.collectionSelectionHandler != nil)
    {
        self.collectionSelectionHandler(collectionForIndexPath);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - Private Methods

- (PHFetchResult *)fetchResultForAssetsInCollection:(PHAssetCollection *)collection
{
    PHFetchResult *resultForCollection = [self.cachedFetchResultsForCollections objectForKey:collection];
    if (resultForCollection == nil)
    {
        resultForCollection = [PHAsset fetchAssetsInAssetCollection:collection
                                                            options:nil];
        [self.cachedFetchResultsForCollections setObject:resultForCollection
                                                  forKey:collection];
    }
    return resultForCollection;
}

@end
