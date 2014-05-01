//
//  VKeyboardBarViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCameraViewController.h"
#import "VObjectManager+Comment.h"
#import "VKeyboardBarViewController.h"
#import "VLoginViewController.h"

@interface VKeyboardBarViewController() <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (nonatomic, strong) NSString*  mediaExtension;
@property (nonatomic, strong) NSURL* mediaURL;

@end

@implementation VKeyboardBarViewController

- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:0 context:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mediaButton.layer.cornerRadius = 2;
    self.mediaButton.clipsToBounds = YES;
}

- (IBAction)sendButtonAction:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    [self.textView resignFirstResponder];
    [self.delegate keyboardBar:self didComposeWithText:self.textView.text mediaURL:self.mediaURL mediaExtension:self.mediaExtension];
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textView.text = nil;
    self.mediaExtension = nil;
    self.mediaURL = nil;
}

- (void)cameraPressed:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL, NSString *mediaExtension)
    {
        if (finished)
        {
            self.mediaURL = capturedMediaURL;
            self.mediaExtension = mediaExtension;
            [self.mediaButton setImage:previewImage forState:UIControlStateNormal];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (NSAttributedString *)textViewText
{
    return self.textView.attributedText;
}

- (void)setTextViewText:(NSAttributedString *)textViewText
{
    self.textView.attributedText = textViewText;
    if ([self respondsToSelector:@selector(textViewDidChange:)])
    {
        [self textViewDidChange:self.textView];
    }
}

- (BOOL)becomeFirstResponder
{
    return [self.textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.promptLabel.hidden = ![textView.text isEqualToString:@""];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
    {
        [self.delegate keyboardBar:self wouldLikeToBeResizedToHeight:(14.0f + self.textView.contentSize.height)];
    }
}

@end
