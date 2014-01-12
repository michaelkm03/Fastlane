//
//  VComposeViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComposeViewController.h"
#import "VObjectManager+Comment.h"
#import "VSequence.h"

@interface VComposeViewController()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation VComposeViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

- (IBAction)cameraButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
}

- (IBAction)stickerButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
}

- (IBAction)sendButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
    if([self.textField.text length])
    {
        [[[VObjectManager sharedManager] addCommentWithText:self.textField.text Data:nil mediaExtension:nil toSequence:self.sequence andParent:nil successBlock:^(NSArray *resultObjects) {
            NSLog(@"%@", resultObjects);
        } failBlock:^(NSError *error) {
            NSLog(@"%@", error);
        }] start];
        self.textField.text = nil;
    }
}

@end
