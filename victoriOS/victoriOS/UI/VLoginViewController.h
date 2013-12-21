//
//  VLoginViewController.h
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

extern  NSString*   const   kVLoginViewControllerDomain;

NS_ENUM(NSInteger, VLoginViewControllerErrorCode)
{
    VLoginViewControllerBadUsernameErrorCode,
    VLoginViewControllerBadPasswordErrorCode
};

@interface VLoginViewController : UITableViewController  <UITextFieldDelegate>

+ (VLoginViewController *)sharedLoginViewController;

@end
