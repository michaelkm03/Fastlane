//
//  VMarqueeViewController.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStream, VStreamItem, VStreamCollectionViewDataSource, VMarqueeViewController;

@protocol VMarqueeDelegate <NSObject>

@required

- (UINavigationController *)navigationControllerForMarquee:(VMarqueeViewController *)marquee;

@end

@interface VMarqueeViewController : UIViewController

@property (nonatomic, weak) id<VMarqueeDelegate> delegate;
@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
@property (strong, nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.
@property (weak, nonatomic, readonly) UICollectionView *collectionView;///<The colletion view used to display the streamItems

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

@end
