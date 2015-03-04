//
//  VProfileCreateViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"
#import "VRegistrationModel.h"
#import "VAuthorizationViewController.h"

extern NSString * const VProfileCreateViewControllerWasAbortedNotification;

@class VUser;

@interface VProfileCreateViewController : UIViewController <VAuthorizationViewController>

@property (nonatomic, strong) void (^authorizationCompletionAction)();

@property (nonatomic, assign)   VLoginType      loginType;
@property (nonatomic, strong)   VUser          *profile;
@property (nonatomic, strong)   VRegistrationModel *registrationModel;

+ (VProfileCreateViewController *)profileCreateViewController;

@end
