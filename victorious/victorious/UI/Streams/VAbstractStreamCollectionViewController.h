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
@property (nonatomic, strong) VStream *defaultStream;///<The default stream
@property (nonatomic, strong) NSArray *allStreams;///<All streams that can display

@property (nonatomic, strong) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.  NOTE: a subclass is responsible for creating / setting its on data source in view did load.

@property (nonatomic, weak, readonly) UICollectionView *collectionView;///<The collection view used to display the streamItems

@property (nonatomic, weak) id<UIScrollViewDelegate> delegate;///<Optional scrollViewDelegate in case this VC is a child VC.

@property (nonatomic) UIEdgeInsets contentInset;///<The default content inset that will be used when the view appears.  Will not be used if this VC has a nav header.

- (IBAction)refresh:(UIRefreshControl *)sender;
- (void)refreshWithCompletion:(void(^)(void))completionBlock;

@end
