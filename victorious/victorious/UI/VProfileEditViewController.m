//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"
#import "VUser.h"
#import "MBProgressHUD.h"

#import "VObjectManager+Login.h"

@interface VProfileEditViewController ()
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@end

@implementation VProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"cameraButtonBack"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"cameraButtonBack"]];

    self.nameLabel.text = self.profile.name;
    
    [self.usernameTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Profile Edit"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (IBAction)done:(UIBarButtonItem *)sender
{
    [[self view] endEditing:YES];
    sender.enabled = NO;
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Save Profile" label:nil value:nil];

    MBProgressHUD*  progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    progressHUD.detailsLabelText = NSLocalizedString(@"ProfileSave", @"");

    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                         name:self.usernameTextField.text
                                              profileImageURL:self.updatedProfileImage
                                                     location:self.locationTextField.text
                                                      tagline:self.taglineTextView.text
                                                 successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [progressHUD hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
                                                    failBlock:^(NSOperation* operation, NSError* error)
    {
        [progressHUD hide:YES];
        sender.enabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"ProfileSaveFail", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

@end
