//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"

@interface VProfileEditViewController ()  <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation VProfileEditViewController

- (IBAction)cancel:(id)sender
{
    NSLog(@"CANCEL PRESSED");
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
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"avatar.jpg"] applyLightEffect]];
    self.tableView.backgroundView = backgroundImageView;
    
    [self setTableProperties];
//    
//    // Set table view header (unneccessary)
//    self.tableView.tableHeaderView = ({
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        imageView.image = [UIImage imageNamed:@"avatar.jpg"];
//        imageView.layer.masksToBounds = YES;
//        imageView.layer.cornerRadius = 50.0;
////        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
////        imageView.layer.borderWidth = 3.0f;
//        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        imageView.layer.shouldRasterize = YES;
//        imageView.clipsToBounds = YES;
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
//        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
//        [label sizeToFit];
//        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        
//        [view addSubview:imageView];
//        [view addSubview:label];
//        view;
//    });
}

- (void)setTableProperties
{
    self.tableView.opaque = NO;
        
//    UIColor* transparentWhite = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
//    self.tableView.backgroundColor = transparentWhite;
    
    // hacky - fix later
    self.nameTextField.tag = 0;
    self.usernameTextField.tag = 1;
    self.locationTextField.tag = 2;
    self.longDescriptionTextField.tag = 3;
    
    self.nameTextField.enabled = YES;
    self.usernameTextField.enabled = YES;
    self.locationTextField.enabled = YES;
//    self.longDescriptionTextField;
    
    self.nameTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.longDescriptionTextField.delegate = self;
    
    self.nameTextField.opaque = NO;
    self.usernameTextField.opaque = NO;
    self.locationTextField.opaque = NO;
    self.longDescriptionTextField.opaque = NO;
    
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.usernameTextField.backgroundColor = [UIColor clearColor];
    self.locationTextField.backgroundColor = [UIColor clearColor];
    self.longDescriptionTextField.backgroundColor = [UIColor clearColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // FIXME
    NSIndexPath* indexPath = [[NSIndexPath indexPathWithIndex:0] indexPathByAddingIndex:textField.tag + 1];

    if ([textField isEqual:self.nameTextField])
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.usernameTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.usernameTextField])
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.locationTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.locationTextField])
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.longDescriptionTextField becomeFirstResponder];
    }
    else
        // ATTEMPT TO SAVE HERE
        return NO;
        
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
