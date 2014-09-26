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
    
    UIToolbar *blurredView = [[UIToolbar alloc] initWithFrame:self.blurringContainer.bounds];
    blurredView.translucent = YES;
    blurredView.barStyle = UIBarStyleDefault;
    [self.blurringContainer insertSubview:blurredView
                                  atIndex:0];
}

- (IBAction)pressedCancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
