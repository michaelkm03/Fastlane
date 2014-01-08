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

@property (nonatomic, readwrite) IBOutlet UITextField* nameTextField;
@property (nonatomic, readwrite) IBOutlet UITextField* usernameTextField;
@property (nonatomic, readwrite) IBOutlet UITextField* locationTextField;
@property (nonatomic, readwrite) IBOutlet UITextField* taglineTextField;

@property (nonatomic, readwrite) IBOutlet UIImageView* profileImageView;
@property (nonatomic, readwrite) IBOutlet UIButton* headerButton;

@end

@implementation VProfileEditViewController

- (IBAction)cancel
{
    NSLog(@"Cancel button pressed");
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done
{
    // TODO: Save and send profile details to the server
    NSLog(@"Done button pressed");
    BOOL success = NO;
    if (success)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not save profile data"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)takePicture:(id)sender
{
    NSLog(@"Picture button pressed");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set profile data - returns a BOOL
    [self setProfileData];
    
    [self setHeader];
    [self setTableProperties];
}

- (BOOL)setProfileData
{
    // TODO: Set the background here using core data
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"avatar.jpg"] applyLightEffect]];
    self.tableView.backgroundView = backgroundImageView;
    // TODO: Add code to set the text data here
    return YES;
}

- (void)setHeader
{
    // Create and set the header
    self.profileImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.profileImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 50.0;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    
    self.headerButton.layer.masksToBounds = YES;
    self.headerButton.layer.cornerRadius = 50.0;
    self.headerButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.headerButton.layer.shouldRasterize = YES;
    self.headerButton.clipsToBounds = YES;
    
}

- (void)setTableProperties
{
    self.tableView.scrollEnabled = NO;
    self.tableView.opaque = NO;
    
    // hacky, but works
    // attach indices to the text fields for keyboard scroll
    self.nameTextField.tag = 1;
    self.usernameTextField.tag = 2;
    self.locationTextField.tag = 3;
    self.taglineTextField.tag = 4;
    
    self.nameTextField.enabled = YES;
    self.usernameTextField.enabled = YES;
    self.locationTextField.enabled = YES;
    
    self.nameTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextField.delegate = self;
    
    self.nameTextField.opaque = NO;
    self.usernameTextField.opaque = NO;
    self.locationTextField.opaque = NO;
    self.taglineTextField.opaque = NO;
    
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.usernameTextField.backgroundColor = [UIColor clearColor];
    self.locationTextField.backgroundColor = [UIColor clearColor];
    self.taglineTextField.backgroundColor = [UIColor clearColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Scroll the table view to respective cell
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
        [self.taglineTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.taglineTextField])
    {
        // TODO: push profile info to the server here
        [self.view endEditing:YES];
        return YES;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
