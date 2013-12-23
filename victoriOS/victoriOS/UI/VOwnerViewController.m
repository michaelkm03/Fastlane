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

#warning With a Storyboard initWithCoder is used, not initWithNibName. May not even be needed

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
    
#warning These can be set in IB, and yes, the last one should not be next, either default or Done
    // Change 'Return' to 'Next' in the text fields
    [self.questionTextField setReturnKeyType:UIReturnKeyNext];
    [self.leftVoteTextField setReturnKeyType:UIReturnKeyNext];
    // Last text field should have 'Done', or 'Next'?
    [self.rightVoteTextField setReturnKeyType:UIReturnKeyNext];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // make the keyboard appear when the application launches
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text view delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
#warning This is where you could make sure the textfield is scrolled above the keyboard
#warning This might also be where we attach an accessory view to the keyboard (if needed)
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
#warning No need to resign first responder when you call becomeFirstResponder on another field
    if (textField == self.questionTextField)
    {
        [textField resignFirstResponder];
        [self.leftVoteTextField becomeFirstResponder];
    }
    else if (textField == self.leftVoteTextField)
    {
        [textField resignFirstResponder];
        [self.rightVoteTextField becomeFirstResponder];
    }
    else if (textField == self.rightVoteTextField)
    {
        [textField resignFirstResponder];
        NSLog(@"SEND DATA TO SERVER HERE, OR ADD A PREVIEW");
    }
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

- (void)clearAll
{
    // Hacky - delete twice to remove any pictures
    [self deleteLeft];
    [self deleteLeft];
    // Set text fields to null and placeholder text to original
    self.questionTextField.text = nil;
    self.leftVoteTextField.text = nil;
    self.rightVoteTextField.text = nil;
    
    self.questionTextField.placeholder = @"Ask a question...";
    self.leftVoteTextField.placeholder = @"Vote";
    self.rightVoteTextField.placeholder = @"Vote";
}

- (IBAction)showMenu
{
    [self.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)createPoll
{
//    NSString* question = self.questionTextField.text;
//    NSString* leftVote = self.leftVoteTextField.text;
//    NSString* rightVote = self.rightVoteTextField.text;
    [self clearAll];
}

// Deletes the left image
- (IBAction)deleteLeft
{
    self.leftMediaData = self.rightMediaData;
    self.leftMediaType = self.rightMediaType;
    self.leftImage.image = self.rightImage.image;
    
    self.rightMediaData = nil;
    self.rightMediaType = nil;
    self.rightImage.image = nil;
}

// Deletes the right image
- (IBAction)deleteRight
{
    self.rightMediaData = nil;
    self.rightMediaType = nil;
    self.rightImage.image = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#warning "[self.view endEditing:YES];" is sufficient to use here instead
    
    for (UIView * view in self.view.subviews){
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            [view resignFirstResponder];
        }
    }
}

@end