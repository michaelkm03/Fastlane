//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"
#import "VUser.h"

#import "VObjectManager+Login.h"

@interface VProfileEditViewController ()
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@end

@implementation VProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameLabel.text = self.profile.name;
    
    [self.usernameTextField becomeFirstResponder];
}

- (IBAction)done:(UIBarButtonItem *)sender
{
    [[self view] endEditing:YES];
    sender.enabled = NO;
    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                     username:self.usernameTextField.text
                                              profileImageURL:self.updatedProfileImage
                                                     location:self.locationTextField.text
                                                      tagline:self.taglineTextView.text
                                                 successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VLog(@"Succeeded with objects: %@", resultObjects);
        
        [self.navigationController popViewControllerAnimated:YES];
    }
                                                    failBlock:^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
