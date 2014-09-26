//
//  VMarqueeViewController.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStream, VUser, VStreamItem, VStreamCollectionViewDataSource, VMarqueeViewController;

@protocol VMarqueeDelegate <NSObject>

@required

- (void)marquee:(VMarqueeViewController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path;
- (void)marquee:(VMarqueeViewController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path;

@end

@interface VMarqueeViewController : UIViewController

@property (nonatomic, weak) id<VMarqueeDelegate> delegate;
@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
@property (strong, nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.
@property (weak, nonatomic, readonly) UICollectionView *collectionView;///<The colletion view used to display the streamItems

@property (nonatomic, readonly) NSTimer *autoScrollTimer;///<The timer in control of auto scroll

- (void)scheduleAutoScrollTimer;///Invalidates the current autoScrollTimer and schedules a new timer.

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

@end
