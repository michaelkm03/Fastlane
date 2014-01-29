//
//  VLoginWithEmailViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

extern  NSString*   const   kVLoginErrorDomain;

NS_ENUM(NSUInteger, VLoginErrorCode)
{
    VLoginBadEmailAddressErrorCode,
    VLoginBadPasswordErrorCode,
    VLoginFailedLoginErrorCode
};

@interface VLoginWithEmailViewController : UIViewController
@end
