//
//  VAssetCollectionListViewController.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

@interface VAssetCollectionListViewController : UIViewController

/**
 *  Factory method for this ViewController. Use this to get an instance of VAssetCollectionListViewController.
 */
+ (instancetype)assetCollectionListViewControllerWithMediaType:(PHAssetMediaType)mediaType;

/**
 *  A handler for colleciton selection. Dismisses self after calling this handler.
 */
@property (nonatomic, copy) void (^collectionSelectionHandler)(PHAssetCollection *selectedCollection);

/**
 *  Fetches the collections. Called on the main thread.
 */
- (void)fetchDefaultCollectionWithCompletion:(void (^)(PHAssetCollection *collection))completion;

@end
