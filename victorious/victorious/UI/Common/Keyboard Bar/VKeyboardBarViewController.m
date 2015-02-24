//
//  VKeyboardBarViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"

#import "VContentInputAccessoryView.h"
#import "VObjectManager+Comment.h"
#import "VKeyboardBarViewController.h"
#import "VLoginViewController.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VObjectManager+Login.h"
#import "UIActionSheet+VBlocks.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "VAppDelegate.h"
#import "VUserTaggingTextStorage.h"

static const NSInteger kCharacterLimit = 255;
static const NSInteger VDefaultKeyboardHeight = 51;

@interface VKeyboardBarViewController() <UITextViewDelegate, VWorkspaceFlowControllerDelegate>

@property (nonatomic, weak, readwrite) IBOutlet UIView *textViewContainer;
@property (nonatomic, strong, readwrite) UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;

@end

@implementation VKeyboardBarViewController

- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}

- (void)awakeFromNib
{
    self.shouldAutoClearOnCompose = YES;
    self.sendButtonEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textStorage = [[VUserTaggingTextStorage alloc] initWithString:nil textView:nil taggingDelegate:self.delegate];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textView setBackgroundColor:[UIColor clearColor]];
    self.textView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.textView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    
    //Adding this to the top inset centers the text with it's placeholder
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    textContainerInset.top += 1.0f;
    self.textView.textContainerInset = textContainerInset;
    
    [self.textViewContainer addSubview:self.textView];
    NSDictionary *views = @{@"view":self.textView};
    [self.textViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
    [self.textViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
    self.textView.delegate = self;
    
    [self.textStorage setTextView:self.textView];
    
    [self.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:0 context:nil];
    
    [self addAccessoryBar];
    
    self.promptLabel.textColor = [UIColor lightGrayColor];
    
    [self enableOrDisableSendButtonAsAppropriate];
}

- (void)addAccessoryBar
{
    VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), VDefaultKeyboardHeight)];
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

- (void)clearKeyboardBar
{
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textView.text = nil;
    self.mediaURL = nil;
    [self textViewDidChange:self.textView];
}

- (void)enableOrDisableSendButtonAsAppropriate
{
    self.sendButton.enabled = self.mediaURL || (self.textView.text.length > 0);
}

- (IBAction)sendButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    [self.textView resignFirstResponder];

    if ([self.delegate respondsToSelector:@selector(keyboardBar:didComposeWithText:mediaURL:)])
    {
        NSString *text = [self.textStorage databaseFormattedString];
        [self.delegate keyboardBar:self didComposeWithText:text mediaURL:self.mediaURL];
    }
    if (self.shouldAutoClearOnCompose)
    {
        [self clearKeyboardBar];
    }
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self.textView resignFirstResponder];
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textView.text = nil;
    self.mediaURL = nil;
    
    if ([self.delegate respondsToSelector:@selector(didCancelKeyboardBar:)])
    {
        [self.delegate didCancelKeyboardBar:self];
    }
}

- (void)cameraPressed:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    void (^showCamera)(void) = ^void(void)
    {
        VWorkspaceFlowController *workspaceFlowController = [VWorkspaceFlowController workspaceFlowControllerWithoutADependencyMangerWithInjection:@{VImageToolControllerInitialImageEditStateKey:@(VImageToolControllerInitialImageEditStateFilter),
                                                                                                                                                     VVideoToolControllerInitalVideoEditStateKey:@(VVideoToolControllerInitialVideoEditStateVideo)}];
        workspaceFlowController.delegate = self;
        workspaceFlowController.videoEnabled = YES;
        [self presentViewController:workspaceFlowController.flowRootViewController
                           animated:YES
                         completion:nil];
    };
    
    if (self.mediaURL == nil)
    {
        showCamera();
        return;
    }
    
    // We already have a selected media does the user want to discard and re-take?
    NSString *actionSheetTitle = NSLocalizedString(@"Delete this content and select something else?", @"User has already selected media (pictire/video) as an attachment for commenting.");
    NSString *discardActionTitle = NSLocalizedString(@"Delete", @"Delete the previously selected item. This is a destructive operation.");
    NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Cancel button.");
    
    void (^clearMediaSelection)(void) = ^void(void)
    {
        self.mediaURL = nil;
        [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    };
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:actionSheetTitle
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *discardAction = [UIAlertAction actionWithTitle:discardActionTitle
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action)
                                    {
                                        clearMediaSelection();
                                        showCamera();
                                    }];
    [alertController addAction:discardAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelActionTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
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

- (void)setSendButtonEnabled:(BOOL)sendButtonEnabled
{
    _sendButtonEnabled = sendButtonEnabled;
    if ([self isViewLoaded])
    {
        [self enableOrDisableSendButtonAsAppropriate];
    }
}

- (BOOL)becomeFirstResponder
{
    return [self.textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        switch (textView.returnKeyType)
        {
            case UIReturnKeyGo:
            case UIReturnKeyDone:
            case UIReturnKeySend:
                [textView resignFirstResponder];
                if ([self.delegate respondsToSelector:@selector(didCancelKeyboardBar:)])
                {
                    [self.delegate didCancelKeyboardBar:self];
                }
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
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.promptLabel.hidden = ![textView.text isEqualToString:@""];
    [self enableOrDisableSendButtonAsAppropriate];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
    {
        if ([self.delegate respondsToSelector:@selector(keyboardBar:wouldLikeToBeResizedToHeight:)])
        {
            CGFloat desiredHeight = fmaxf(14.0f + self.textView.contentSize.height, VDefaultKeyboardHeight);
            if (CGRectGetHeight(self.view.bounds) != desiredHeight)
            {
                [self.delegate keyboardBar:self wouldLikeToBeResizedToHeight:desiredHeight];
            }
        }
    }
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    self.mediaURL = capturedMediaURL;
    [self.mediaButton setImage:previewImage forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES
                             completion:^
     {
         [self enableOrDisableSendButtonAsAppropriate];
     }];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

@end
