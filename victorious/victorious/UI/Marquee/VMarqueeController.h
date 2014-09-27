//
//  VMarqueeController.h
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VStream, VUser, VStreamItem, VStreamCollectionViewDataSource, VMarqueeController;

@protocol VMarqueeDelegate <NSObject>

@required

- (void)marquee:(VMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path;
- (void)marquee:(VMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path;

@end

@interface VMarqueeController : NSObject <UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<VMarqueeDelegate> delegate;
@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
@property (strong, nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.
@property (weak, nonatomic) UICollectionView *collectionView;///<The colletion view used to display the streamItems

@property (nonatomic, readonly) NSTimer *autoScrollTimer;///<The timer in control of auto scroll

- (void)disableTimer;
- (void)enableTimer;

@end
