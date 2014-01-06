//
//  VProfileViewController.h
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VProfileEditViewController.h"

@interface VProfileViewController : UIViewController <VProfileEditViewControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

+ (VProfileViewController *)sharedProfileViewController;

@property (nonatomic, readwrite) BOOL userIsLoggedInUser;
@property (nonatomic, readwrite) IBOutlet UIImageView* bg;
@property (nonatomic, readwrite) IBOutlet UITableView* profileDetails;

@end
