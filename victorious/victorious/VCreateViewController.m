//
//  VCreateViewController.m
//  victorious
//
//  Created by David Keegan on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreateViewController.h"
#import "VThemeManager.h"

@interface VCreateViewController()
<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UILabel *mediaLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@end

@implementation VCreateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mediaButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.icon"];
    self.mediaButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.mediaButton.background"];
    self.mediaLabel.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text"];
    self.textView.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text"];
    self.textView.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.text.border"] CGColor];
    self.textView.layer.borderWidth = 1;
    self.postButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.text"];
    self.postButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.postButton.background"];

    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"]
                                     style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardFrameChanged:)
     name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.mediaButton.layer.cornerRadius = CGRectGetHeight(self.mediaButton.bounds)/2;
}

- (IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mediaButtonAction:(id)sender
{
}

- (IBAction)postButtonAction:(id)sender
{
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];

    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        self.contentTopConstraint.constant = -MAX(0, (CGRectGetHeight(self.view.bounds)-CGRectGetMinY(keyboardEndFrame)-CGRectGetHeight(self.postButton.bounds)));
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

@end
