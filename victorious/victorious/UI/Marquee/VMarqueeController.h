//
//  VMarqueeController.h
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class VStream, VUser, VStreamItem, VStreamCollectionViewDataSource, VMarqueeController, VMarqueeTabIndicatorView, VTimerManager, VDependencyManager;

@protocol VMarqueeSelectionDelegate <NSObject>

@required

- (void)marquee:(VMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image;
- (void)marquee:(VMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path;

@end

@protocol VMarqueeDataDelegate <NSObject>

@required

- (void)marquee:(VMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems;

@end

@interface VMarqueeController : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, weak) id <VMarqueeSelectionDelegate> selectionDelegate;
@property (nonatomic, weak) id <VMarqueeDataDelegate> dataDelegate;

@property (nonatomic, readonly) VStreamItem *currentStreamItem;///<The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream;///<The Marquee Stream
@property (weak, nonatomic) UICollectionView *collectionView;///<The colletion view used to display the streamItems
@property (weak, nonatomic) VMarqueeTabIndicatorView *tabView;///<The Marquee tab view to update
@property (nonatomic, readonly) VTimerManager *autoScrollTimerManager;///<The timer in control of auto scroll
@property (nonatomic, assign) BOOL hideMarqueePosterImage;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (instancetype)initWithStream:(VStream *)stream;
- (void)disableTimer;
- (void)enableTimer;

@end
