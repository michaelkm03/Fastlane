//
//  VLoginWithEmailViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRegistration.h"

typedef NS_ENUM(NSUInteger, VLoginErrorCode)
{
    VLoginErrorCodeBadEmailAddress,
    VLoginErrorCodeBadPassword,
    VLoginErrorCodeFailedLogin
};

@class VDependencyManager;

@interface VLoginWithEmailViewController : UIViewController <VRegistrationStep, VRegistrationStepDelegate>

@property (nonatomic, weak) IBOutlet UIView *transitionPlaceholder;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
