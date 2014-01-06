//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"

@interface VProfileEditViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation VProfileEditViewController

- (IBAction)cancel:(id)sender
{
    NSLog(@"CANCEL PRESSED");
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
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
    
    
    // Set table view properties
//    self.editProfileDetails.delegate = self;
//    self.editProfileDetails.dataSource = self;
    self.editProfileDetails.opaque = NO;
    self.editProfileDetails.backgroundColor = [UIColor clearColor];
    // Set table view header (unneccessary)
    self.editProfileDetails.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"avatar.jpg"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
}

// Only 3 parameters for the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UITextField* textField = [[UITextField alloc]initWithFrame:cell.frame];
    textField.delegate = self;
    textField.text = @"TEST";
    [cell addSubview:textField];
    return cell;
}

// Scroll to display text field when editing
- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self.editProfileDetails scrollToRowAtIndexPath:[self cellIndexPathForField:textField] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}
// Get the indx of the cell that we're editing
- (NSIndexPath *)cellIndexPathForField:(UITextField *)textField
{
    UIView *view = textField;
    while (![view isKindOfClass:[UITableViewCell class]])
    {
        view = [view superview];
    }
    return [self.editProfileDetails indexPathForCell:(UITableViewCell *)view];
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//- (void)textFieldDidEndEditing:(UITextField*)textField
//{
//    [self.editProfileDetails replaceObjectAtIndex:textField.tag withObject:textField.text];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
