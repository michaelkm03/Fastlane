//
//  VNewServerEnvironmentViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNewServerEnvironmentViewController.h"

@interface VNewServerEnvironmentViewController ()

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *urlTextField;

@end

@implementation VNewServerEnvironmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)save:(id)sender
{
    NSString *name = self.nameTextField.text;
    NSString *url = self.urlTextField.text;
    
    
}

@end
