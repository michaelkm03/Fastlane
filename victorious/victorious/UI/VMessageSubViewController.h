//
//  VMessageSubViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationSubViewController.h"

@class VConversation;

@interface VMessageSubViewController : VConversationSubViewController
@property (nonatomic, readwrite, strong)    VConversation*  conversation;
@end
