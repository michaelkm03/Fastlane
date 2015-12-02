//
//  VProfileCreateViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginType.h"
#import "VRegistrationModel.h"
#import "VRegistration.h"

@class VUser, VDependencyManager;

@interface VProfileCreateViewController : UIViewController <VRegistrationStep>

@property (nonatomic, assign) VLoginType loginType;
@property (nonatomic, strong) VUser *profile;
@property (nonatomic, strong) VRegistrationModel *registrationModel;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (VProfileCreateViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
