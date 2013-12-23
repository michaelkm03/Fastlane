//
//  VEmailLoginViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/5/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

extern  NSString*   const   kSignupViewControllerDomain;

NS_ENUM(NSUInteger, VLoginViewControllerErrorCode)
{
    VSignupViewControllerBadUsernameErrorCode,
    VSignupViewControllerBadPasswordErrorCode,
    VSignUpViewControllerBadEmailAddressErrorCode
};

@interface VSignUpViewController : UITableViewController <UITextFieldDelegate>
@end
