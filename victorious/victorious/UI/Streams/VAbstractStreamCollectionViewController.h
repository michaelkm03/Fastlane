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

@interface VAbstractStreamCollectionViewController : UIViewController <VStreamCollectionDataDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIRefreshControl *refreshControl;///<Refresh control for the collectionview
@property (nonatomic, strong) VStream *currentStream;///<The stream to display

@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.  NOTE: a subclass is responsible for creating / setting its on data source in view did load.

@property (nonatomic, weak, readonly) UICollectionView *collectionView;///<The collection view used to display the streamItems

@property (nonatomic, readonly) CGFloat topInset; ///< An amount by which to inset the top of the content in the collection view.
@property (nonatomic) BOOL navigationBarShouldAutoHide; ///< Set to YES to hide the navigation bar on scroll

@property (nonatomic, assign) BOOL didTrackViewDidAppear; //< Tracking helper, prevents duplicate events
@property (nonatomic, assign) BOOL canTrackViewDidAppear; //< Tracking helper, prevents tracking views before enough data about the stream has been loaded

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

/**
 Designed to be overidden in subclasses so diffrent types of streams can respond to
 handling tracking their event in their own way.
 */
- (void)trackStreamDidAppear;


@end
