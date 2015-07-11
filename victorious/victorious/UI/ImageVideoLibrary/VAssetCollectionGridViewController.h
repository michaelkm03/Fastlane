//
//  VAssetGridViewController.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMediaSource.h"

@import Photos;
@class VDependencyManager;

@interface VAssetCollectionGridViewController : UICollectionViewController <VMediaSource>

/**
 *  Factory method for this ViewController. Use this to grab a new instance of assetGridViewController;
 */
+ (instancetype)assetGridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
                                                   mediaType:(PHAssetMediaType)mediaType;

/**
 *  Set this to the collection you want to display in the grid.
 */
@property (nonatomic, strong) PHAssetCollection *collectionToDisplay;

/**
 *  Provide the gridViewController a selection handelr to be notified when the user selects an item in the grid. 
 *  Called on the main thread.
 */
@property (nonatomic, copy) void (^alternateFolderSelectionHandler)();

/**
 *  Assign a handler to be notified when the user has granted or denied permission to the user's library. 
 *  Called immediately if the user has already responded to the system authorization prompt.
 */
@property (nonatomic, copy) void (^onAuthorizationHandler)(BOOL authorized);

@end
