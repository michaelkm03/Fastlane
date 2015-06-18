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

@property (nonatomic, strong) UICollectionView *collectionView;

@end
