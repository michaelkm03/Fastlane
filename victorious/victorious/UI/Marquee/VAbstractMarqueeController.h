//
//  VBaseMarqueeController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VStreamCollectionViewDataSource.h"

@class VDependencyManager, VStream, VStreamItem, VStreamCollectionViewDataSource, VTimerManager, VUser, VAbstractMarqueeController;

@protocol VMarqueeControllerDelegate <NSObject>

@required

- (void)marquee:(VAbstractMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image;
- (void)marqueeRefreshedContent:(VAbstractMarqueeController *)marquee;

@end

@interface VAbstractMarqueeController : NSObject <VStreamCollectionDataDelegate>

@property (nonatomic, weak) id <VMarqueeControllerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;///<The colletion view used to display the streamItems
@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
@property (nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource;///<The VStreamCollectionViewDataSource for the object.
@property (nonatomic, readonly) VTimerManager *autoScrollTimerManager;///<The timer in control of auto scroll
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, readonly) NSInteger currentPage;

- (instancetype)initWithStream:(VStream *)stream;
- (void)disableTimer;
- (void)enableTimer;
- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock;

- (NSTimeInterval)timerFireInterval;
- (void)scrolledToPage:(NSInteger)currentPage;

- (NSString *)cellSuggestedReuseIdentifier;
- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

@end
