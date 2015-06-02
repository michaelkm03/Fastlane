//
//  VEnterResetTokenViewController.h
//  victorious
//
//  Created by Will Long on 6/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRegistration.h"

@class VDependencyManager;

@interface VEnterResetTokenViewController : UIViewController <VRegistrationStep, VRegistrationStepDelegate>

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (instancetype)enterResetTokenViewController;

@end