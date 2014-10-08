//
//  VAbstractStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStream, VStreamCollectionViewDataSource, VNavigationHeaderView;

@interface VAbstractStreamCollectionViewController : UIViewController

@property (nonatomic, strong) UIRefreshControl *refreshControl;///<Refresh control for the collectionview
@property (nonatomic, strong) VStream *currentStream;///<The stream to display
@property (nonatomic, strong) VStream *defaultStream;///<The default stream
@property (nonatomic, strong) NSArray *allStreams;///<All streams that can display

@property (nonatomic, strong, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.

@property (nonatomic, weak, readonly) UICollectionView *collectionView;///<The colletion view used to display the streamItems
@property (nonatomic, weak) VNavigationHeaderView *navHeaderView;///<The navigation header for the stream

@property (nonatomic, assign) BOOL shouldShowHeaderLogo;

- (IBAction)refresh:(UIRefreshControl *)sender;

@end
