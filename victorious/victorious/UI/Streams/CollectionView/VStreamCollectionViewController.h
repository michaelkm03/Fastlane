//
//  VStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAbstractStreamCollectionViewController.h"

@class VStreamCollectionViewDataSource;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController

@property (nonatomic) BOOL shouldDisplayMarquee;
@property (nonatomic, strong) UIView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.

+ (instancetype)homeStreamCollection;
+ (instancetype)communityStreamCollection;
+ (instancetype)ownerStreamCollection;

+ (instancetype)streamViewControllerForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams title:(NSString *)title;
+ (instancetype)streamViewControllerForStream:(VStream *)stream;

@end
