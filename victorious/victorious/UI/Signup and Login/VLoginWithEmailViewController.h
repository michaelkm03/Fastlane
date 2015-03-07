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

@interface VLoginWithEmailViewController : UIViewController <VRegistrationStep>

@property (nonatomic, weak) IBOutlet UIView *transitionPlaceholder;

@end
