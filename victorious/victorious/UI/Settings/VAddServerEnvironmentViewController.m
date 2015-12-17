//
//  VNewServerEnvironmentViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAddServerEnvironmentViewController.h"
#import "VEnvironment.h"
#import "VEnvironmentManager.h"

@interface VAddServerEnvironmentViewController ()

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *urlTextField;
@property (nonatomic, weak) IBOutlet UITextField *appIDTextField;

@end

@implementation VAddServerEnvironmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    self.urlTextField.text = @"http://";
}

- (IBAction)save:(id)sender
{
    NSString *name = self.nameTextField.text;
    NSString *url = self.urlTextField.text;
    NSNumber *appId = @(self.appIDTextField.text.integerValue);
    
    VEnvironment *environment = [[VEnvironment alloc] initWithName:name baseURL:[NSURL URLWithString:url] appID:appId];
    BOOL success = [[VEnvironmentManager sharedInstance] addEnvironment:environment];
    
    if ( success )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        __weak typeof(self) welf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Unable to create that environment."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
            [welf dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
