//
//  VAbstractStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VPageType.h"
#import "VStreamCollectionViewDataSource.h"
#import "VStreamTrackingHelper.h"
#import "VNavigationViewFloatingController.h"
#import "VNavigationControllerScrollDelegate.h"
#import "VHasManagedDependencies.h"

NS_ASSUME_NONNULL_BEGIN

static const CGFloat VStreamMarqueeParallaxRatio = 0.5f;

@class VStream, VNavigationHeaderView, VCollectionRefreshControl;

/**
    A view controller setup to display, track, and interact with stream content
 */
@interface VAbstractStreamCollectionViewController : UIViewController <VStreamCollectionDataDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIRefreshControl *refreshControl;///<Refresh control for the collectionview
@property (nonatomic, strong) VStream *currentStream;///<The stream to display
@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;

/**
    The VStreamCollectionViewDataSource for the object.  NOTE: a subclass is responsible for creating / setting its on data source in view did load.
 */
@property (nonatomic, strong, nullable) VStreamCollectionViewDataSource *streamDataSource;

@property (nonatomic, null_unspecified, strong) IBOutlet UICollectionView *collectionView;///<The collection view used to display the streamItems

@property (nonatomic, readonly) CGFloat topInset; ///< An amount by which to inset the top of the content in the collection view.
@property (nonatomic) BOOL navigationBarShouldAutoHide; ///< Set to YES to hide the navigation bar on scroll

@property (nonatomic, strong) VStreamTrackingHelper *streamTrackingHelper; ///< An aide for sending tracking events
@property (nonatomic, strong, nullable) VNavigationControllerScrollDelegate *navigationControllerScrollDelegate;
@property (nonatomic, strong, nullable) id<VNavigationViewFloatingController> navigationViewfloatingController;

@property (nonatomic, strong, nullable) VStreamItem *targetStreamItem; ///< The stream item that should be scroll to once this VC becomes visible

/**
    Called by the refresh controller when the user activates it by scrolling up to the top.
        Forwards onto `refreshWithCompletion:`.
 */
- (IBAction)refresh:(nullable UIRefreshControl *)sender;

/**
    A helper method to handle triggering the refresh and responding to success or failure.
 */
- (void)loadPage:(VPageType)pageType completion:(void(^ __nullable)(void))completionBlock;

/**
    Called when a condition that affects UGC permissions may have changed for the stream
        and a the presennce of the create content button should be updated.
 */
- (void)updateNavigationItems;

@end

NS_ASSUME_NONNULL_END
