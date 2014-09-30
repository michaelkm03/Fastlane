//
//  VProfileCreateViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"
#import "VRegistrationModel.h"

static NSString * const kCreateProfileAborted = @"CreateProfileAborted";

@class VUser;

@interface VProfileCreateViewController : UIViewController
@property (nonatomic, assign)   VLoginType      loginType;
@property (nonatomic, strong)   VUser          *profile;
@property (nonatomic, strong)   VRegistrationModel *registrationModel;

@end
