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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.delegate  =   self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    //     Reduce the size of the text view so that it's not obscured by the keyboard.
    //     Animate the resize so that it's in sync with the appearance of the keyboard.

    NSDictionary *userInfo = [notification userInfo];

    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

    // Get the top of the keyboard as the y coordinate of its origin in self's view's
    // coordinate system. The bottom of the text view's frame should align with the top
    // of the keyboard's final position.
    //
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    //     Restore the size of the text view (fill self's view).
    //     Animate the resize so that it's in sync with the disappearance of the keyboard.

    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

#pragma mark - Accessory view action

- (IBAction)tappedAccessoryView:(id)sender
{

}

@end
