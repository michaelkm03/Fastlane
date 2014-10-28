//
//  VMultipleStreamViewController.h
//  victorious
//
//  Created by Will Long on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VNewContentViewController.h"

@interface VMultipleStreamViewController : UIViewController <VNewContentViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL shouldDisplayMarquee;

+ (instancetype)homeStream;
+ (instancetype)communityStream;
+ (instancetype)ownerStream;

@end
