//
//  VMessageSubViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"

@class VUnreadMessageCountCoordinator, VUser;

@interface VMessageContainerViewController : VKeyboardBarContainerViewController

@property (nonatomic, readonly) VUser  *otherUser;
@property (nonatomic, weak) IBOutlet UIView *busyView;
@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic, assign) BOOL presentingFromProfile;

+ (instancetype)messageViewControllerForUser:(VUser *)otherUser;

@end
