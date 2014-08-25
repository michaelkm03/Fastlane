//
//  VMessageSubViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"

@class VUser;

@interface VMessageContainerViewController : VKeyboardBarContainerViewController

@property (nonatomic, strong) VUser *otherUser;

+ (instancetype)messageContainer;

@end
