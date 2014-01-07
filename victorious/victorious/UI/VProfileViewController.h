//
//  VProfileViewController.h
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"

@interface VProfileViewController : UIViewController

+ (VProfileViewController *)sharedProfileViewController;

@property (nonatomic, readwrite) BOOL userIsLoggedInUser;

@end
