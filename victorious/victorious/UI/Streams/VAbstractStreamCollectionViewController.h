//
//  VAbstractStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VStreamCollectionViewDataSource.h"
#import "VStreamTrackingHelper.h"
#import "VMultipleContainer.h"

@class VStream, VNavigationHeaderView, VCollectionRefreshControl;

/**
    A view controller setup to display, track, and interact with stream content
 */
@interface VAbstractStreamCollectionViewController : UIViewController <VStreamCollectionDataDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, VMultipleContainerChild>

@property (nonatomic, strong) UIRefreshControl *refreshControl;///<Refresh control for the collectionview
@property (nonatomic, strong) VStream *currentStream;///<The stream to display

/**
    The VStreamCollectionViewDataSource for the object.  NOTE: a subclass is responsible for creating / setting its on data source in view did load.
 */
@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;

@property (nonatomic, weak, readonly) UICollectionView *collectionView;///<The collection view used to display the streamItems

@property (nonatomic, readonly) CGFloat topInset; ///< An amount by which to inset the top of the content in the collection view.
@property (nonatomic) BOOL navigationBarShouldAutoHide; ///< Set to YES to hide the navigation bar on scroll

@property (nonatomic, strong) VStreamTrackingHelper *streamTrackingHelper; ///< An aide for sending tracking events

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
    Called when a condition that affects UGC permissions may have changed for the stream
        and a the presennce of the create content button should be updated.
 */
- (void)updateUserPostAllowed;

@end
