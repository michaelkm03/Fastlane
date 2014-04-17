//
//  VStreamsSubViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"

@class VSequence;

@interface VCommentsContainerViewController : VKeyboardBarContainerViewController
@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, weak) UIViewController* parentVC;

+ (instancetype)commentsContainerView;

@end
