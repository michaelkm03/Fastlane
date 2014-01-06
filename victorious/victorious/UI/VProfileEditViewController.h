//
//  VProfileEditViewController.h
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VProfileEditViewController;

@interface VProfileEditViewController : UIViewController

@property (nonatomic, readwrite) IBOutlet UIImageView* backgroundImageView
;
@property (nonatomic, readwrite) IBOutlet UITableView* editProfileDetails;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
