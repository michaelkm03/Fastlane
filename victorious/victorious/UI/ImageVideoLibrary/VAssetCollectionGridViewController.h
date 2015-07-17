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
 *  User has selected a particular asset.
 */
- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController
             selectedAsset:(PHAsset *)asset;

@end

/**
 *  Must inject a PHAssetMediaType using the key: 
 */
@interface VAssetCollectionGridViewController : UIViewController <VHasManagedDependencies>

/**
 *  A delegate to be informed of events related to this gridViewController.
 */
@property (nonatomic, weak) id <VAssetCollectionGridViewControllerDelegate> delegate;

/**
 *  Set this to the collection you want to display in the grid.
 */
@property (nonatomic, strong) PHAssetCollection *collectionToDisplay;

@end
