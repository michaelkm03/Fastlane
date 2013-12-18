//
//  VComposeMessageViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VComposeMessageViewController.h"

@interface VComposeMessageViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@end

@implementation VComposeMessageViewController
{
    CGSize      _keyboardSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.delegate  =   self;
    self.textView.keyboardDismissMode   =   UIScrollViewKeyboardDismissModeInteractive;
    self.textView.scrollEnabled =   YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    // make the keyboard appear when the application launches
    [super viewWillAppear:animated];

    // start editing the UITextView
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)compose:(id)sender
{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    if (self.textView.inputAccessoryView == nil)
        self.textView.inputAccessoryView = self.accessoryView;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView
{
    [aTextView resignFirstResponder];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [textView scrollRangeToVisible:range];
    return YES;
}

#pragma mark - Responding to keyboard events

- (void)keyboardDidShow:(NSNotification *)notification
{
    _keyboardSize   =   [[notification userInfo][@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue].size;
    [self updateTextViewSize];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    _keyboardSize   =   CGSizeMake(0.0, 0.0);
    [self updateTextViewSize];
}

- (void)updateTextViewSize
{
    UIInterfaceOrientation  orientation =   [UIApplication sharedApplication].statusBarOrientation;
    CGFloat     keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? _keyboardSize.width : _keyboardSize.height;
    self.textView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight);
}

#pragma mark - Accessory view action

- (IBAction)cameraButtonClicked:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
//    imagePicker.delegate = self;

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    else
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
