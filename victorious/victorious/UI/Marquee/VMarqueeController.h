//
//  VMarqueeController.h
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class VStream, VUser, VStreamItem, VStreamCollectionViewDataSource, VMarqueeController, VMarqueeTabIndicatorView;

@protocol VMarqueeDelegate <NSObject>

@required

- (void)marquee:(VMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image;
- (void)marquee:(VMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path;
- (void)marqueeRefreshedContent:(VMarqueeController *)marquee;

@end

@interface VMarqueeController : NSObject <UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<VMarqueeDelegate> delegate;
@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
@property (strong, nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.
@property (weak, nonatomic) UICollectionView *collectionView;///<The colletion view used to display the streamItems
@property (weak, nonatomic) VMarqueeTabIndicatorView *tabView;///<The Marquee tab view to update
@property (nonatomic, readonly) NSTimer *autoScrollTimer;///<The timer in control of auto scroll

- (instancetype)initWithStream:(VStream *)stream;
- (void)disableTimer;
- (void)enableTimer;
- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock;

@end
