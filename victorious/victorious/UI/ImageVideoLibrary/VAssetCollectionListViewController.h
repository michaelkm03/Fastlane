//
//  VAssetCollectionListViewController.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;

@interface VAssetCollectionListViewController : UITableViewController

/**
 *  Factory method for this ViewController. Use this to get an instance of VAssetCollectionListViewController.
 */
+ (instancetype)assetCollectionListViewController;

/**
 *  A handler for colleciton selection. Dismisses self after calling this handler.
 */
@property (nonatomic, copy) void (^collectionSelectionHandler)(PHAssetCollection *selectedCollection);

@end
