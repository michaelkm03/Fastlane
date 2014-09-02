//
//  VSignupWithEmailViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VSignupErrorCode)
{
    VSignupErrorCodeBadUsername,
    VSignupErrorCodeBadPassword,
    VSignupErrorCodeBadEmailAddress
};

@interface VSignupWithEmailViewController : UIViewController

@end
