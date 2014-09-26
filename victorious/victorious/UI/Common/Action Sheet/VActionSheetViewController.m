//
//  VActionSheetViewController.m
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetViewController.h"

@interface VActionSheetViewController ()

@property (weak, nonatomic) IBOutlet UIView *blurringContainer;
@property (weak, nonatomic) IBOutlet UITableView *actionItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation VActionSheetViewController

+ (VActionSheetViewController *)actionSheetViewController
{
    UIStoryboard *ourStoryboard = [UIStoryboard storyboardWithName:@"ActionSheet" bundle:nil];
    return [ourStoryboard instantiateInitialViewController];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    UIToolbar *blurredView = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.blurringContainer.bounds),
                                                                         CGRectGetHeight(self.blurringContainer.bounds) * 2.0f)];
    blurredView.translucent = YES;
    blurredView.barStyle = UIBarStyleDefault;
    blurredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blurringContainer insertSubview:blurredView
                                  atIndex:0];
}

- (IBAction)pressedCancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)pressedTapAwayButton:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                     completion:nil];
}

@end
