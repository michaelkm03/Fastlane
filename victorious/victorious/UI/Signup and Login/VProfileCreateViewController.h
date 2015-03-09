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
#import "VRegistration.h"

@class VUser;

@interface VProfileCreateViewController : UIViewController <VAuthorizationViewController, VRegistrationStep>

@property (nonatomic, assign) VLoginType loginType;
@property (nonatomic, strong) VUser *profile;
@property (nonatomic, strong) VRegistrationModel *registrationModel;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (VProfileCreateViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
