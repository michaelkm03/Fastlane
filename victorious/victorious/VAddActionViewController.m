//
//  VAddActionViewController.m
//  victorious
//
//  Created by David Keegan on 12/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAddActionViewController.h"

@interface VAddActionViewController()
@end

@implementation VAddActionViewController

- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)videoButtonAction:(id)sender {
    [self.delegate addActionViewController:self didChooseAction:VAddActionViewControllerTypeVideo];
}

- (IBAction)imageButtonAction:(id)sender {
    [self.delegate addActionViewController:self didChooseAction:VAddActionViewControllerTypeImage];
}

- (IBAction)pollButtonAction:(id)sender {
    [self.delegate addActionViewController:self didChooseAction:VAddActionViewControllerTypePoll];
}

@end
