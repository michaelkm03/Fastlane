//
//  VAbstractStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VStreamCollectionViewDataSource.h"

@class VStream, VNavigationHeaderView, VCollectionRefreshControl;

@interface VAbstractStreamCollectionViewController : UIViewController <VStreamCollectionDataDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;///<Refresh control for the collectionview
@property (nonatomic, strong) VStream *currentStream;///<The stream to display

@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.  NOTE: a subclass is responsible for creating / setting its on data source in view did load.

@property (nonatomic, weak, readonly) UICollectionView *collectionView;///<The collection view used to display the streamItems

@property (nonatomic) UIEdgeInsets contentInset;///<The default content inset that will be used when the view appears.  Will not be used if this VC has a nav header.

/**
 Called by the refresh controller when the user activates it by scrolling up to the top.
 Forwards onto `refreshWithCompletion:`.
 */
- (IBAction)refresh:(UIRefreshControl *)sender;

/**
 A helper method to handle triggering the refresh and responding to success or failure.
 */
- (void)refreshWithCompletion:(void(^)(void))completionBlock;

/**
 Intended to be called by subclasses on `collectionView:willDisplayCell:atIndexPath:` to
 trigger an animation for newly loaded cells where appropriate.
 */
- (void)animateNewlyPopulatedCell:(UICollectionViewCell *)cell
                 inCollectionView:(UICollectionView *)collectionView
                      atIndexPath:(NSIndexPath *)indexPath;

@end
