//
//  VNewServerEnvironmentViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNewServerEnvironmentViewController.h"
#import "VEnvironmentManager.h"

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
    NSNumber *appId = [[NSBundle mainBundle] objectForInfoDictionaryKey:VAppIDKey];
    
    VEnvironment *environment = [[VEnvironment alloc] initWithName:name baseURL:[NSURL URLWithString:url] appID:appId];
    [[VEnvironmentManager sharedInstance] addEnvironment:environment];
}

@end
