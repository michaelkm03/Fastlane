//
//  VChangePasswordViewController.h
//  victorious
//
//  Created by Gary Philipp on 6/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern  NSString*   const   kAccountUpdateViewControllerDomain;

NS_ENUM(NSUInteger, VAccountUpdateViewControllerErrorCode)
{
    VAccountUpdateViewControllerBadPasswordErrorCode
};

@interface VChangePasswordViewController : UIViewController
@end
