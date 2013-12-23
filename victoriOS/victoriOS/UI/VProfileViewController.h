//
//  VProfileViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VUser;

@interface VProfileViewController : UITableViewController   <UITextFieldDelegate>
@property (nonatomic, readwrite)    BOOL    userIsLoggedInUser;
@property (nonatomic, readwrite)    VUser*  user;
@end
