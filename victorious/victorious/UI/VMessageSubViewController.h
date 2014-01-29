//
//  VMessageSubViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComposeContainerViewController.h"

@class VConversation;

@interface VMessageSubViewController : VComposeContainerViewController
@property (nonatomic, readwrite, strong)    VConversation*  conversation;
@end
