//
//  VResetPasswordViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRegistration.h"

@interface VResetPasswordViewController : UIViewController <VRegistrationStep>

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userToken;

@end
