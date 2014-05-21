//
//  VSignupWithEmailViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

extern  NSString*   const   kSignupErrorDomain;

NS_ENUM(NSUInteger, VSignupErrorCode)
{
    VSignupBadUsernameErrorCode,
    VSignupBadPasswordErrorCode,
    VSignUpBadEmailAddressErrorCode
};

@interface VSignupWithEmailViewController : UIViewController
@end
