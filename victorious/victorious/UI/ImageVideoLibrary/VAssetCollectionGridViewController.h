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

@class VAssetCollectionGridViewController;

@protocol VAssetCollectionGridViewControllerDelegate <NSObject>

/**
 *  Notifies delegate the user wants to pick a different asset collection.
 */
- (void)gridViewControllerWantsToViewAlternateCollections:(VAssetCollectionGridViewController *)gridViewController;

/**
 *  User has selected a particular asset.
 */
- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController
             selectedAsset:(PHAsset *)asset;

/**
 *  User has taken an action that has updated the authorization status for their asset gallery.
 */
- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController
       authorizationStatus:(BOOL)authorizedStatus;

@end

/**
 *  Must inject a PHAssetMediaType using the key: 
 */
@interface VAssetCollectionGridViewController : UICollectionViewController <VHasManagedDependencies>

/**
 *  A delegate to be informed of events related to this gridViewController.
 *
 *  NOTE: the "gridViewController:authorizationStatus:" method is called immediately if the user has already answered 
 *  the system prompt after setting this delegate method.
 */
@property (nonatomic, weak) id <VAssetCollectionGridViewControllerDelegate> delegate;

/**
 *  Set this to the collection you want to display in the grid.
 */
@property (nonatomic, strong) PHAssetCollection *collectionToDisplay;

@end
