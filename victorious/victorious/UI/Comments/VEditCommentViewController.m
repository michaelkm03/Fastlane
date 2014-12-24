//
//  VEditCommentViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEditCommentViewController.h"
#import "VComment.h"
#import "VThemeManager.h"
#import "VObjectManager+Comment.h"
#import "VAlertController.h"

@interface VEditCommentViewController() <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *modalContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewVerticalAlignmentConstraint;
@property (weak, nonatomic) IBOutlet UITextView *editTextView;

@property (strong, nonatomic) VComment *comment;

@end

@implementation VEditCommentViewController

+ (VEditCommentViewController *)instantiateFromStoryboardWithComment:(VComment *)comment
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EditComment" bundle:nil];
    VEditCommentViewController *viewController = (VEditCommentViewController *)[storyboard instantiateInitialViewController];
    viewController.comment = comment;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.modalContainer.layer.cornerRadius = 2.0f;
    self.modalContainer.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    self.modalContainer.layer.borderWidth = 1.0f;
    
    self.editTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.editTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.editTextView.returnKeyType = UIReturnKeyDone;
    
    self.editTextView.delegate = self;
    self.editTextView.text = self.comment.text;
    
    [self updateSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.editTextView becomeFirstResponder];
    
    [self updateSize];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setButtonsVisible:NO delay:0.0f];
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateSize
{
    CGSize size = [self.editTextView sizeThatFits:CGSizeMake( CGRectGetWidth(self.editTextView.frame), CGFLOAT_MAX )];
    
    [UIView animateWithDuration:0.35f delay:0.0f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.4f
                        options:kNilOptions animations:^void
     {
         self.modalContainerHeightConstraint.constant = size.height + self.textViewTopConstraint.constant + self.textViewBottomConstraint.constant;
         
         // Animates this element
         [self.modalContainer layoutIfNeeded];

         // Animates subviews, specifically the attached confirm/cancel buttons
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

- (void)dismiss
{
    // Prevents another rapid return key press from dismissing previous view as well (mostly happens in simulator)
    self.editTextView.delegate = nil;

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateCommentText:(NSString *)text
{
    return text != nil && text.length > 0;
}

#pragma mark - IBActions

- (IBAction)onBackgroundTapped:(id)sender
{
    // Do nothing for now
}

- (IBAction)onConfirm:(id)sender
{
    self.comment.text = self.editTextView.text;
    
    [[VObjectManager sharedManager] editComment:self.comment
                                   successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         
         VLog( @"Comment edit succeeded!" );
     }
                                      failBlock:^(NSOperation *operation, NSError *error)
     {
         VLog( @"Comment edit failed: %@", error.localizedDescription );
     }];
    
    if ( self.delegate != nil )
    {
        [self.delegate didFinishEditingComment:self.comment];
    }
    else
    {
        [self dismiss];
    }
}

- (IBAction)onCancel:(id)sender
{
    [self dismiss];
}

#pragma mark - Button animations

- (void)setButtonsVisible:(BOOL)visible delay:(NSTimeInterval)delay
{
    if ( visible )
    {
        self.buttonCancel.hidden = NO;
        self.buttonConfirm.hidden = NO;
        self.buttonCancel.alpha = 0.0f;
        self.buttonConfirm.alpha = 0.0f;
    }
    
    [UIView animateWithDuration:0.3f delay:delay options:kNilOptions animations:^
    {
        self.buttonCancel.alpha = visible ? 1.0f : 0.0f;
        self.buttonConfirm.alpha = visible ? 1.0f : 0.0f;
    }
                     completion:^(BOOL finished)
     {
         if ( !visible )
         {
             self.buttonCancel.hidden = YES;
             self.buttonConfirm.hidden = YES;
         }
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    // As in other comment entry sections of the app, we just disable the confirm button
    // if the comment text is invalid
    self.buttonConfirm.enabled = [self validateCommentText:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] )
    {
        if ( [self validateCommentText:textView.text] )
        {
            [self onConfirm:nil];
        }
        return NO;
    }
    
    [self updateSize];
    
    return YES;
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat height = CGRectGetHeight( [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] );
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
     {
         self.textViewVerticalAlignmentConstraint.constant = height * 0.5f;
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         [self setButtonsVisible:YES delay:0.4f];
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
     {
         self.textViewVerticalAlignmentConstraint.constant = 0.0f;
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

@end
