//
//  VImageVideoLibraryViewController.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageVideoLibraryViewController.h"

// ViewControllers
#import "VAssetGridViewController.h"
#import "VAssetCollectionListViewController.h"

// Views + Helpers
#import "VFlexBar.h"
#import "VCompatibility.h"

@import Photos;

@interface VImageVideoLibraryViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) IBOutlet VFlexBar *alternateCaptureOptionsFlexBar;

@property (nonatomic, weak) VAssetGridViewController *gridViewController;

@end

@implementation VImageVideoLibraryViewController

@synthesize handler;

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboardForImageVideoGallery = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                             bundle:[NSBundle bundleForClass:self]];
    return [storyboardForImageVideoGallery instantiateInitialViewController];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"albumsPopover"])
    {
        // Set delegate to self so we can show as a real popover (Non-adaptive).
        VAssetCollectionListViewController *destinationViewController = (VAssetCollectionListViewController *)segue.destinationViewController;
        destinationViewController.assetCollections = [self assetCollectionsForContentType:VAssetTypePhoto];
        __weak typeof(self) welf = self;
        destinationViewController.collectionSelectionHandler = ^void(PHAssetCollection *collection)
        {
            welf.gridViewController.assetsToDisplay = [PHAsset fetchAssetsInAssetCollection:collection
                                                                                    options:nil];
        };
        
        destinationViewController.popoverPresentationController.delegate = self;
        // Inset the popover a bit
        CGSize preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 50.0f,
                                                 CGRectGetHeight(self.view.bounds) - 200.0f);
        destinationViewController.preferredContentSize = preferredContentSize;
    }
    else if ([segue.identifier isEqualToString:@"assetGridEmbed"])
    {
        self.gridViewController = segue.destinationViewController;
        self.gridViewController.handler = ^void(UIImage *previewImage, NSURL *capturedMediaURL)
        {
            if (self.handler)
            {
                self.handler(previewImage, capturedMediaURL);
            }
        };
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
                                                               traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

#pragma mark - Private Methods

- (NSArray *)assetCollectionsForContentType:(VAssetType)type
{
    // Fetch all albums
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:fetchOptions];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny
                                                                         options:fetchOptions];

    // Figure out Photos media type based on our media type
    PHAssetMediaType mediaType = (type == VAssetTypePhoto) ? PHAssetMediaTypeImage : PHAssetMediaTypeVideo;
    PHFetchOptions *mediaTypeOptions = [[PHFetchOptions alloc] init];
    mediaTypeOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", mediaType];
    
    // Add collections to array if collection contains at least 1 asset of media type
    NSMutableArray *assetCollections = [[NSMutableArray alloc] init];
    for (PHAssetCollection *collection in smartAlbums)
    {
        PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                             options:mediaTypeOptions];
        if (albumMediaTypeResults.count > 0)
        {
            [assetCollections addObject:collection];
        }
    }
    for (PHAssetCollection *collection in userAlbums)
    {
        PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                             options:mediaTypeOptions];
        if (albumMediaTypeResults.count > 0)
        {
            [assetCollections addObject:collection];
        }
    }
    
    return [NSArray arrayWithArray:assetCollections];
}

@end

#pragma mark - VImageLibraryAlternateCaptureOption

@interface VImageLibraryAlternateCaptureOption ()

@property (nonatomic, copy) VImageLibraryAlternateCaptureOption *selectionBlock;

@end

@implementation VImageLibraryAlternateCaptureOption

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
            andSelectionBlock:(VImageVideoLibraryAlternateCaptureSelection)selectionBlock
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _icon = icon;
        _selectionBlock = [selectionBlock copy];
    }
    return self;
}

@end
