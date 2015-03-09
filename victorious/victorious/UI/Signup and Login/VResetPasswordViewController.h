//
//  VResetPasswordViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRegistration.h"

@class VDependencyManager;

@interface VResetPasswordViewController : UIViewController <VRegistrationStep>

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
