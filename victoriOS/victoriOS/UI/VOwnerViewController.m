//
//  VOwnerViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VOwnerViewController.h"

#import "REFrostedViewController.h"
#import "VStreamsTableViewController.h"

@interface VOwnerViewController ()

@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *leftVoteTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightVoteTextField;

@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;

@property (strong, nonatomic) NSData* leftMediaData;
@property (strong, nonatomic) NSString* leftMediaType;
@property (strong, nonatomic) NSData* rightMediaData;
@property (strong, nonatomic) NSString* rightMediaType;

@end

@implementation VOwnerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.questionTextField.delegate = self;
    self.leftVoteTextField.delegate = self;
    self.rightVoteTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    // make the keyboard appear when the application launches
    [super viewWillAppear:animated];
    
    // start editing the UITextView
    [self.questionTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text view delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [super imagePickerController:picker didFinishPickingMediaWithInfo:info];
    if (self.mediaData == nil || self.mediaType == nil)
    {
        // Failed to pick image - maybe imagepicker should return a boolean
        return;
    }
    // Set the left media data/type if nil
    if (self.leftMediaData == nil || self.leftMediaType == nil)
    {
        self.leftMediaData = self.mediaData;
        self.leftMediaType = self.mediaType;
        self.leftImage.image = [UIImage imageWithData:self.leftMediaData];
        
    }
    // if right is nil, set right media data/type
    else if (self.rightMediaData == nil || self.rightMediaType == nil)
    {
        self.rightMediaData = self.mediaData;
        self.rightMediaType = self.mediaType;
        self.rightImage.image = [UIImage imageWithData:self.rightMediaData];
    }
    else
    {
        // if both media data/type exists, don't do anything
        return;
    }
}

// OVERRIDE CANCEL
- (IBAction)cancel:(id)sender
{
    // RETURN TO STREAMS FOR NOW
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    VStreamsTableViewController*    streamsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"streams"];
    navigationController.viewControllers = @[streamsViewController];
}

- (IBAction)deleteLeft
{
    self.leftMediaData = self.rightMediaData;
    self.leftMediaType = self.rightMediaType;
    self.leftImage.image = self.rightImage.image;
    
    self.rightMediaData = nil;
    self.rightMediaType = nil;
    self.rightImage.image = nil;
}

- (IBAction)deleteRight
{
    self.rightMediaData = nil;
    self.rightMediaType = nil;
    self.rightImage.image = nil;
}


@end