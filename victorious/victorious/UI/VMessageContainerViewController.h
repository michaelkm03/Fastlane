//
//  VMessageSubViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"

@class VConversation;

@interface VMessageContainerViewController : VKeyboardBarContainerViewController
@property (nonatomic, readwrite, strong)    VConversation*  conversation;

+ (instancetype)messageContainer;

@end
