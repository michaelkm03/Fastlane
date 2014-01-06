//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"

@interface VProfileEditViewController ()

@end

@implementation VProfileEditViewController


- (IBAction)cancel:(id)sender
{
    [self.delegate profileEditViewControllerDidCancel:self];
    NSLog(@"CANCEL PRESSED");
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
    [self.delegate profileEditViewControllerDidSave:self];
    NSLog(@"DONE PRESSED");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // FIXME: SET BACKGROUND
    UIImage* bg = [[UIImage imageNamed:@"avatar.jpg"] applyLightEffect];
    self.bg.image = bg;
    self.bg.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
