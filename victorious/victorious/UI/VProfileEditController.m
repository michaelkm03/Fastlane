//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditController.h"
#import "UIImage+ImageEffects.h"
#import "VUser.h"

@interface VProfileEditViewController ()
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@end

@implementation VProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameLabel.text = self.profile.shortName;
    
    [self.usernameTextField becomeFirstResponder];
}

- (IBAction)done:(id)sender
{
    // TODO: Save and send profile details to the server
    [self.navigationController popViewControllerAnimated:YES];
}

@end
