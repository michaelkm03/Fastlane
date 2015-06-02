//
//  VSignupWithEmailViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRegistration.h"

@class VDependencyManager;

@interface VSignupWithEmailViewController : UIViewController <VRegistrationStep, VRegistrationStepDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
