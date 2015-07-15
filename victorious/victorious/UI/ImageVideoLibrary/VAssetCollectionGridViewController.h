//
//  VAssetGridViewController.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
@import Photos;

extern NSString * const VAssetCollectionGridViewControllerMediaType;

/**
 *  Must inject a PHAssetMediaType using the key: 
 */
@interface VAssetCollectionGridViewController : UICollectionViewController <VHasManagedDependencies>

/**
 *  Set this to the collection you want to display in the grid.
 */
@property (nonatomic, strong) PHAssetCollection *collectionToDisplay;

/**
 *  Provide the gridViewController a selection handler to be notified when the user requests the other folders in their library.
 *  Called on the main thread.
 */
@property (nonatomic, copy) void (^alternateFolderSelectionHandler)();

/**
 *  Provide the gridViewController a selection handler to be notified when the user selects an item in the grid.
 */
@property (nonatomic, copy) void (^assetSelectionHandler)(PHAsset *selectedAsset);

/**
 *  Assign a handler to be notified when the user has granted or denied permission to the user's library. 
 *  Called immediately if the user has already responded to the system authorization prompt.
 */
@property (nonatomic, copy) void (^onAuthorizationHandler)(BOOL authorized);

@end
