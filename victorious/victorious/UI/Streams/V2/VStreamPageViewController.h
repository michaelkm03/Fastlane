//
//  VStreamPageViewController.h
//  victorious
//
//  Created by Will Long on 10/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VStreamPageViewController : UIPageViewController

@property (nonatomic) BOOL shouldDisplayMarquee;

+ (instancetype)homeStream;
+ (instancetype)communityStream;
+ (instancetype)ownerStream;

@end
