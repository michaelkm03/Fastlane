//
//  VProfileEditViewController.h
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VProfileEditViewController;

@interface VProfileEditViewController : UITableViewController

@property (nonatomic, readwrite) IBOutlet UIImageView* profileImageView;

@property (nonatomic, readwrite) IBOutlet UITextField* nameTextField;
@property (nonatomic, readwrite) IBOutlet UITextField* usernameTextField;
@property (nonatomic, readwrite) IBOutlet UITextField* locationTextField;
@property (nonatomic, readwrite) IBOutlet UITextView* longDescriptionTextField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
