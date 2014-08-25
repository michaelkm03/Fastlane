//
//  VKeyboardBarViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCameraViewController.h"
#import "VContentInputAccessoryView.h"
#import "VObjectManager+Comment.h"
#import "VKeyboardBarViewController.h"
#import "VLoginViewController.h"

static const NSInteger kCharacterLimit = 255;

@interface VKeyboardBarViewController() <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
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
    
    [self addAccessoryBar];
    
    self.promptLabel.textColor = [UIColor lightGrayColor];
    
    self.sendButton.enabled = (self.textView.text.length > 0);
}



- (void)addAccessoryBar
{
    VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 44.0f)];
    inputAccessoryView.textInputView = self.textView;
    inputAccessoryView.maxCharacterLength = kCharacterLimit;
    inputAccessoryView.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];

    self.textView.inputAccessoryView = inputAccessoryView;
}

- (void)setHideAccessoryBar:(BOOL)hideAccessoryBar
{
    if (hideAccessoryBar && self.textView.inputAccessoryView)
    {
        self.textView.inputAccessoryView = nil;
    }
    else if (!hideAccessoryBar && !self.textView.inputAccessoryView)
    {
        [self addAccessoryBar];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mediaButton.layer.cornerRadius = 2;
    self.mediaButton.clipsToBounds = YES;
}

- (IBAction)sendButtonAction:(id)sender
{
    if (self.textView.text.length < 1)
    {
        return;
    }
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    [self.textView resignFirstResponder];

    if ([self.delegate respondsToSelector:@selector(keyboardBar:didComposeWithText:mediaURL:)])
        [self.delegate keyboardBar:self didComposeWithText:self.textView.text mediaURL:self.mediaURL];
    
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textView.text = nil;
    self.mediaURL = nil;
    [self textViewDidChange:self.textView];
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textView.text = nil;
    self.mediaURL = nil;
    
    if ([self.delegate respondsToSelector:@selector(didCancelKeyboardBar:)])
        [self.delegate didCancelKeyboardBar:self];
}

- (void)cameraPressed:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            self.mediaURL = capturedMediaURL;
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
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        switch (textView.returnKeyType) {
            case UIReturnKeyGo:
            case UIReturnKeyDone:
            case UIReturnKeySend:
                [textView resignFirstResponder];
                if ([self.delegate respondsToSelector:@selector(didCancelKeyboardBar:)])
                    [self.delegate didCancelKeyboardBar:self];
                return NO;
                break;
            case UIReturnKeyDefault:
            case UIReturnKeyGoogle:
            case UIReturnKeyJoin:
            case UIReturnKeyNext:
            case UIReturnKeyRoute:
            case UIReturnKeySearch:
            case UIReturnKeyYahoo:
            case UIReturnKeyEmergencyCall:
            default:
                break;
        }
    }
    
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.sendButton.enabled = (newText.length > 0);
    
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
        if ([self.delegate respondsToSelector:@selector(keyboardBar:wouldLikeToBeResizedToHeight:)])
        {
            CGFloat desiredHeight = 14.0f + self.textView.contentSize.height;
            if (CGRectGetHeight(self.view.bounds) != desiredHeight)
            {
                [self.delegate keyboardBar:self wouldLikeToBeResizedToHeight:desiredHeight];
            }
        }
    }
}

@end
