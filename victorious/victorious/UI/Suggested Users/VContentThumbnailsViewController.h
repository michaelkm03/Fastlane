//
//  VContentThumbnailsViewController.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A very generic view controller designed to display a collection view with simple
 horizontal scrolling, publicly exposed to allow a data source to be plugged in.
 */
@interface VContentThumbnailsViewController : UIViewController

/**
 Exposed publicly to allow calling code to create this view controller
 and a datasource for the collection view and hook them up.
 */
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end
