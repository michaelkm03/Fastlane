//
//  VStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAbstractStreamCollectionViewController.h"
#import "VSequenceActionsDelegate.h"

@class VStreamCollectionViewDataSource;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VSequenceActionsDelegate>

@property (nonatomic, weak) id<VSequenceActionsDelegate>actionDelegate;///<Optional param.  If this is not set, the collection view will act as the action delegate for the cells.  Use this if you are embedding this view controller somewhere (i.e. the page view controller)
@property (nonatomic) BOOL shouldDisplayMarquee;
@property (nonatomic, strong) UIView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.

+ (instancetype)homeStreamCollection;
+ (instancetype)communityStreamCollection;
+ (instancetype)ownerStreamCollection;
+ (instancetype)hashtagStreamWithHashtag:(NSString *)hashtag;

+ (instancetype)streamViewControllerForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams title:(NSString *)title;
+ (instancetype)streamViewControllerForStream:(VStream *)stream;

@end
