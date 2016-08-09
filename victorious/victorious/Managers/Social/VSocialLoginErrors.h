//
//  VSocialLoginErrors.h
//  victorious
//
//  Created by Patrick Lynch on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//


extern NSString * const VTwtterErrorDomain;
extern NSString * const VFacebookErrorDomain;

typedef NS_ENUM(NSInteger, VSocialLoginError)
{
    VSocialLoginErrorCancelled,
    VSocialLoginErrorFailed,
    VSocialLoginErrorUnavailable,
    VSocialLoginErrorDenied
};
