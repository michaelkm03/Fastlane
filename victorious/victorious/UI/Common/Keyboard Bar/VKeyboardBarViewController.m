//
//  VKeyboardBarViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarViewController.h"

#import "VMediaAttachmentPresenter.h"
#import "VContentInputAccessoryView.h"
#import "VObjectManager+Login.h"
#import "UIActionSheet+VBlocks.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "VAppDelegate.h"
#import "VUserTaggingTextStorage.h"
#import "VDependencyManager.h"
#import "VTag.h"
#import "VTagStringFormatter.h"

static const CGFloat kTextInputFieldMaxLines = 3.0f;

@interface VKeyboardBarViewController() <UITextViewDelegate>

@property (nonatomic, weak, readwrite) IBOutlet UIView *textViewContainer;
@property (nonatomic, strong, readwrite) UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) VPublishParameters *publishParameters;
@property (nonatomic, strong) VMediaAttachmentPresenter *attachmentPresenter;

@property (nonatomic, assign, readonly) CGFloat maxTextFieldHeight;

@end

@implementation VKeyboardBarViewController

- (void)dealloc
{
    [_textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
    _textView.delegate = nil;
}

- (void)awakeFromNib
{
    self.shouldAutoClearOnCompose = YES;
    self.sendButtonEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createTextView];
    
    [self addAccessoryBar];
    
    self.promptLabel.textColor = [UIColor lightGrayColor];
    
    self.mediaButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self enableOrDisableSendButtonAsAppropriate];
}

- (void)createTextView
{
    UIFont *defaultFont = [UIFont fontWithName:@"Helvetica" size:16.0f];
    
    self.textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:nil defaultFont:defaultFont taggingDelegate:self.delegate dependencyManager:self.dependencyManager];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textView setBackgroundColor:[UIColor clearColor]];
    self.textView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.textView.font = defaultFont;
    
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
    
    _maxTextFieldHeight = ([defaultFont lineHeight] * kTextInputFieldMaxLines) + [self.delegate initialHeightForKeyboardBar:self];
    [self.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:0 context:nil];
}

- (void)addAccessoryBar
{
    VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), [self.delegate initialHeightForKeyboardBar:self])];
    inputAccessoryView.textInputView = self.textView;
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

#pragma mark - public methods

- (void)setReplyRecipient:(VUser *)user
{
    [self.textStorage repliedToUser:user];
    self.promptLabel.hidden = (self.textStorage.textView.text != nil);
}

- (void)clearKeyboardBar
{
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textView.text = nil;
    self.publishParameters.mediaToUploadURL = nil;
    [self textViewDidChange:self.textView];
}

- (void)enableOrDisableSendButtonAsAppropriate
{
    NSString *textWithoutSpace = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.sendButton.enabled = self.publishParameters.mediaToUploadURL != nil || (textWithoutSpace.length > 0);
}

- (IBAction)sendButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(canPerformAuthorizedAction)])
    {
        if ( ![self.delegate canPerformAuthorizedAction] )
        {
            return;
        }
    }

    if ([self.delegate respondsToSelector:@selector(keyboardBar:didComposeWithText:publishParameters:)])
    {
        NSString *text = [self.textStorage databaseFormattedString];
        [self.delegate keyboardBar:self didComposeWithText:text publishParameters:self.publishParameters];
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
    self.publishParameters.mediaToUploadURL = nil;
    
    if ([self.delegate respondsToSelector:@selector(didCancelKeyboardBar:)])
    {
        [self.delegate didCancelKeyboardBar:self];
    }
}

- (void)cameraPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(canPerformAuthorizedAction)])
    {
        if ( ![self.delegate canPerformAuthorizedAction] )
        {
            return;
        }
    }
    
    void (^showCamera)(void) = ^void(void)
    {
        self.attachmentPresenter = [[VMediaAttachmentPresenter alloc] initWithDependencymanager:self.dependencyManager];
        __weak typeof(self) welf = self;
        self.attachmentPresenter.attachmentTypes = VMediaAttachmentOptionsImage | VMediaAttachmentOptionsVideo | VMediaAttachmentOptionsGIF;
        self.attachmentPresenter.resultHandler = ^void(BOOL success, VPublishParameters *publishParameters)
        {
            __strong typeof(self) strongSelf = welf;
            if (success)
            {
                strongSelf.publishParameters = publishParameters;
                [strongSelf.mediaButton setImage:publishParameters.previewImage forState:UIControlStateNormal];
            }
            [strongSelf dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [strongSelf enableOrDisableSendButtonAsAppropriate];
             }];
        };
        [self.attachmentPresenter presentOnViewController:self];
    };
    
    if (self.publishParameters.mediaToUploadURL == nil)
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
        self.publishParameters.mediaToUploadURL = nil;
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
    if ([self.delegate respondsToSelector:@selector(canPerformAuthorizedAction)])
    {
        if ( ![self.delegate canPerformAuthorizedAction] )
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        if ([self.delegate respondsToSelector:@selector(didCancelKeyboardBar:)])
        {
            [self.delegate didCancelKeyboardBar:self];
        }
    }
    
    if ( self.characterLimit != 0 )
    {
        return [textView.text stringByReplacingCharactersInRange:range withString:text].length <= self.characterLimit;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.promptLabel.hidden = ([textView.text length] != 0);
    [self enableOrDisableSendButtonAsAppropriate];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
    {
        if ([self.delegate respondsToSelector:@selector(keyboardBar:wouldLikeToBeResizedToHeight:)])
        {
            CGFloat desiredHeight = fmaxf(self.textView.contentSize.height, [self.delegate initialHeightForKeyboardBar:self]);
            if (desiredHeight < self.maxTextFieldHeight)
            {
                [self.delegate keyboardBar:self wouldLikeToBeResizedToHeight:desiredHeight];
            }
        }
    }
}

@end
