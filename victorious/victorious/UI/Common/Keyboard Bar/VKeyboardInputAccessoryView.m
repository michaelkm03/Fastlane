//
//  VKeyboardInputAccessoryView.m
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardInputAccessoryView.h"
#import "VUserTaggingTextStorage.h"

// Layout
#import "UIView+AutoLayout.h"
#import "VCompatibility.h"
#import "UIImage+Cropping.h"

// Constants
#import "VConstants.h"

// DependencyManager
#import "VDependencyManager.h"

#import "victorious-Swift.h"

static const NSInteger kCharacterLimit = 255;
static const CGFloat VTextViewTopInsetAddition = 2.0f;
static const CGFloat kAttachmentThumbnailWidth = 35.0f;
static const CGFloat kCommentBarVerticalPaddingToTextView = 10.0f;
static const CGFloat kMaxTextViewHeight = 160.0f;
static const CGFloat kMinTextViewHeight = 40.0f;
static const CGFloat kAttachmentBarHeight = 50.0f;

static NSString * const kCommentPrompt = @"commentPrompt";
static NSString * const kConfirmationText = @"commentConfirmationText";
static NSString * const kCommentBarKey = @"commentBar";

@interface VKeyboardInputAccessoryView () <UITextViewDelegate>

@property (nonatomic, assign) BOOL selectedMedia;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;
@property (nonatomic, assign) CGSize lastContentSize;
@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) NSNumberFormatter *remainingCharacterFormater;

// Views
@property (nonatomic, strong) IBOutlet UIButton *attachmentsButton;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet UIView *editingTextSuperview;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UIButton *imageButton;
@property (nonatomic, strong) IBOutlet UIButton *videoButton;
@property (nonatomic, strong) IBOutlet UIButton *gifButton;
@property (nonatomic, strong) IBOutlet UILabel *remainingCharacterLabel;
@property (nonatomic, weak) UITextView *editingTextView;

// Constraints
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topSpaceAttachmentsToContainer;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *attachmentsBarHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *attachmentButtonWidthConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *commentUIContainerHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *editingTextViewTopSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *editingTextViewBottomSpace;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) BOOL addedTextView;

@end

@implementation VKeyboardInputAccessoryView

#pragma mark - Factory Methods

+ (VKeyboardInputAccessoryView *)defaultInputAccessoryViewWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSDictionary *commentBarConfiguration = [dependencyManager templateValueOfType:[NSDictionary class] forKey:kCommentBarKey];
    VDependencyManager *commentBarDependencyManager = [[VDependencyManager alloc] initWithParentManager:dependencyManager
                                                                                          configuration:commentBarConfiguration
                                                                      dictionaryOfClassesByTemplateName:nil];
    
    UINib *nibForInputAccessoryView = [UINib nibWithNibName:NSStringFromClass([self class])
                                                     bundle:nil];
    NSArray *nibContents = [nibForInputAccessoryView instantiateWithOwner:nil
                                                                  options:nil];
    
    VKeyboardInputAccessoryView *accessoryView = [nibContents firstObject];
    
    accessoryView.dependencyManager = commentBarDependencyManager;
    return accessoryView;
}

#pragma mark - Initialization

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( _dependencyManager != nil )
    {
        if ( !self.addedTextView )
        {
            self.addedTextView = YES;
            [self addTextViewToContainer];
        }
        [self.sendButton setTitleColor:[_dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                              forState:UIControlStateNormal];
        [self.sendButton setTitle:[_dependencyManager stringForKey:kConfirmationText]
                         forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[_dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                              forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor lightGrayColor]
                              forState:UIControlStateDisabled];
        self.sendButton.titleLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        self.placeholderText = [_dependencyManager stringForKey:kCommentPrompt];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.remainingCharacterFormater = [[NSNumberFormatter alloc] init];
    self.remainingCharacterFormater.numberStyle = NSNumberFormatterNoStyle;
    
    // Automation Support
    self.imageButton.accessibilityIdentifier = VAutomationIdentifierCommentBarImageButton;
    self.videoButton.accessibilityIdentifier = VAutomationIdentifierCommentBarVideoButton;
    self.gifButton.accessibilityIdentifier = VAutomationIdentifierCommentBarGIFButton;
    self.sendButton.accessibilityIdentifier = VAutomationIdentifierCommentBarSendButton;
}

- (void)setSequencePermissions:(VSequencePermissions *)sequencePermissions
{
    _sequencePermissions = sequencePermissions;
    self.gifButton.hidden = !sequencePermissions.canAddGifComments;
}

- (void)addTextViewToContainer
{
    UIFont *defaultFont = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    self.textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:nil defaultFont:defaultFont taggingDelegate:self.textStorageDelegate dependencyManager:self.dependencyManager];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    UITextView *editingTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    editingTextView.accessibilityIdentifier = VAutomationIdentifierCommentBarTextView;
    editingTextView.translatesAutoresizingMaskIntoConstraints = NO;
    editingTextView.delegate = self;
    editingTextView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    editingTextView.backgroundColor = [UIColor clearColor];
    editingTextView.font = defaultFont;
    editingTextView.keyboardType = UIKeyboardTypeTwitter;
    
    //Adding this to the top inset centers the text with it's placeholder
    UIEdgeInsets textContainerInset = editingTextView.textContainerInset;
    textContainerInset.top += VTextViewTopInsetAddition;
    editingTextView.textContainerInset = textContainerInset;
    
    editingTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;

    [self.editingTextSuperview addSubview:editingTextView];
    self.editingTextView = editingTextView;
    
    self.textStorage.textView = self.editingTextView;
    
    [self.editingTextSuperview v_addFitToParentConstraintsToSubview:editingTextView];
}

#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *superResult = [super hitTest:point withEvent:event];
    if (superResult == self)
    {
        // Self should pass-through our containers will take everything else
        return nil;
    }
    return superResult;
}

- (CGSize)intrinsicContentSize
{
    CGFloat editingTextViewPadding = self.editingTextViewTopSpace.constant + self.editingTextViewBottomSpace.constant;
    CGFloat contentSizeHeight = self.editingTextView.contentSize.height;
    CGFloat heightSum = editingTextViewPadding + contentSizeHeight;
    CGSize intrinsicSize = CGSizeMake(CGRectGetWidth(self.bounds), CLAMP(kAttachmentBarHeight, heightSum, kMaxTextViewHeight + kAttachmentBarHeight + kCommentBarVerticalPaddingToTextView));
    return intrinsicSize;
}

- (BOOL)stopEditing
{
    [self.textStorage dismissButtonWasPressedInTableView:nil];
    return [self.editingTextView resignFirstResponder];
}

#pragma mark - Property Accessors

- (void)setTextStorageDelegate:(id<VUserTaggingTextStorageDelegate>)textStorageDelegate
{
    _textStorageDelegate = textStorageDelegate;
    self.textStorage.taggingDelegate = textStorageDelegate;
    self.textStorage.textView = self.editingTextView;
}

- (NSString *)composedText
{
    NSString *composedText = [self.textStorage databaseFormattedString];
    return composedText ?: @"";
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    if (_placeholderText != nil)
    {
        self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:placeholderText
                                                                               attributes:[self textEntryAttributes]];
    }
}

- (void)setSelectedThumbnail:(UIImage *)selectedThumbnail
{
    self.attachmentsButton.layer.cornerRadius = 2.0f;
    self.attachmentsButton.layer.masksToBounds = YES;
    self.attachmentsButton.clipsToBounds = YES;
    
    UIImage *croppedThumbnail = [selectedThumbnail squareImageScaledToSize:MIN(selectedThumbnail.size.width, selectedThumbnail.size.height)];
    [self.attachmentsButton setBackgroundImage:croppedThumbnail forState:UIControlStateNormal];

    self.selectedMedia = (selectedThumbnail != nil);
    
    [self updateAttachmentThumbnail];
    [self updateSendButton];
    [self updateAttachmentsBar];
}

- (void)setAttachmentsBarHidden:(BOOL)attachmentsBarHidden
{
    _attachmentsBarHidden = attachmentsBarHidden;
    [self updateAttachmentsBar];
}

#pragma mark - Public Methods

- (void)startEditing
{
    [self.editingTextView becomeFirstResponder];
}

- (BOOL)isEditing
{
    return [self.editingTextView isFirstResponder];
}

- (void)clearTextAndResign
{
    self.editingTextView.text = nil;
    self.sendButton.enabled = NO;
    self.selectedThumbnail = nil;
    self.attachmentsButton.alpha = 1.0f;
    self.selectedMedia = NO;
    [self.attachmentsButton setImage:nil
                            forState:UIControlStateNormal];
    self.attachmentsButton.selected = NO;

    [self.editingTextView resignFirstResponder];
    [self textViewDidChange:self.editingTextView];
}

- (void)setReplyRecipient:(VUser *)user
{
    [self.textStorage repliedToUser:user];
    self.placeholderLabel.hidden = (self.textStorage.textView.text.length == 0) ? NO : YES;
}

#pragma mark - IBActions

- (IBAction)tappedImage:(id)sender
{
    [self.delegate keyboardInputAccessoryView:self
                       selectedAttachmentType:VKeyboardBarAttachmentTypeImage];
}

- (IBAction)tappedVideo:(id)sender
{
    [self.delegate keyboardInputAccessoryView:self
                       selectedAttachmentType:VKeyboardBarAttachmentTypeVideo];
}

- (IBAction)tappedGIF:(id)sender
{
    [self.delegate keyboardInputAccessoryView:self
                       selectedAttachmentType:VKeyboardBarAttachmentTypeGIF];
}

- (IBAction)pressedSend:(id)sender
{
    [self.delegate pressedSendOnKeyboardInputAccessoryView:self];
}

- (IBAction)tappedMediaAttachment:(id)sender
{
    [self.delegate keyboardInputAccessoryViewWantsToClearMedia:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.placeholderLabel.hidden = (textView.text.length == 0) ? NO : YES;
    
    if (!CGSizeEqualToSize(self.lastContentSize, textView.contentSize))
    {
        // New size
        [self invalidateIntrinsicContentSize];
        self.lastContentSize = textView.contentSize;
        CGFloat textViewSize = CLAMP(kMinTextViewHeight, textView.contentSize.height, kMaxTextViewHeight);
        self.commentUIContainerHeightConstraint.constant = textViewSize + kCommentBarVerticalPaddingToTextView;
    }
    
    if (textView.text.length == 0)
    {
        if ([self.delegate respondsToSelector:@selector(keyboardInputAccessoryViewDidClearInput:)])
        {
            [self.delegate keyboardInputAccessoryViewDidClearInput:self];
        }
    }
    
    [self updateSendButton];
    
    //Keeps currently selected range in view and fixes odd issue where top of text is cut off after layout
    [self.editingTextView scrollRangeToVisible:self.editingTextView.selectedRange];
}

- (NSInteger)characterLimit
{
    return kCharacterLimit;
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        // Strip out newline characters and replace with a space
        NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString *stringByRemovingNewlines = [components componentsJoinedByString:@""];
        BOOL hasCharactersOtherThanNewLine = stringByRemovingNewlines.length > 0;

        if (components.count > 0 && hasCharactersOtherThanNewLine)
        {
            NSString *newString = [components componentsJoinedByString:@" "];
            textView.text = newString;
            [self textViewDidChange:textView];
        }
    
        return NO;
    }
    
    NSInteger unicodeLength = string.lengthWithUnicode;
    BOOL shouldChange = unicodeLength <= self.characterLimit;
    
    if (shouldChange)
    {
        NSUInteger remainingCharacterCount = [self characterLimit] - unicodeLength;
        self.remainingCharacterLabel.text = [self.remainingCharacterFormater stringFromNumber:@(remainingCharacterCount)];
        [UIView animateWithDuration:0.8
                         animations:^
        {
            self.remainingCharacterLabel.alpha = (remainingCharacterCount < 20) ? 1.0f : 0.0f;
        }];
    }
    
    return shouldChange;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self updateAttachmentsBar];
    
    if ([self.delegate respondsToSelector:@selector(keyboardInputAccessoryViewDidEndEditing:)])
    {
        [self.delegate keyboardInputAccessoryViewDidEndEditing:self];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateAttachmentsBar];
    
    if ([self.delegate respondsToSelector:@selector(keyboardInputAccessoryViewDidBeginEditing:)])
    {
        [self.delegate keyboardInputAccessoryViewDidBeginEditing:self];
    }
}

#pragma mark - Convenience

- (void)animateAttachmentsBarAnimations:(void (^)(void))animations
{
    NSParameterAssert(animations != nil);
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:kNilOptions
                     animations:^
     {
         animations();
         [self layoutIfNeeded];
     }
                     completion:nil];
}

- (NSDictionary *)textEntryAttributes
{
    return @{ NSFontAttributeName : [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey] };
}

- (void)updateSendButton
{
    NSString *stringWithoutSpace = [self.composedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.sendButton.enabled = (self.selectedMedia || (stringWithoutSpace.length > 0));
}

- (void)updateAttachmentThumbnail
{
    self.attachmentsButton.enabled = self.selectedMedia;
    self.attachmentButtonWidthConstraint.constant = self.selectedMedia ? kAttachmentThumbnailWidth : 0.0f;
}

- (void)updateAttachmentsBar
{
    [self animateAttachmentsBarAnimations:^
     {
         self.topSpaceAttachmentsToContainer.constant = [self shouldShowAttachmentsBar] ? 0.0f : self.attachmentsBarHeightConstraint.constant;
     }];
}

- (BOOL)shouldShowAttachmentsBar
{
    // If set to yes then override default behavior
    if (self.isAttachmentsBarHidden || self.selectedMedia)
    {
        return NO;
    }
    return self.editingTextView.isFirstResponder;
}

@end

@implementation VKeyboardInputAccessoryView (keyboardSize)

- (CGRect)obscuredRectInWindow:(UIWindow *)window
{
    CGRect rectInOwnWindow = [self.window convertRect:self.frame fromView:self.superview];
    CGRect rectInDestinationWindow = [window convertRect:rectInOwnWindow fromWindow:self.window];
    if (![self shouldShowAttachmentsBar])
    {
        rectInDestinationWindow.origin.y = rectInDestinationWindow.origin.y + kAttachmentBarHeight;
        rectInDestinationWindow.size.height = rectInDestinationWindow.size.height - kAttachmentBarHeight;
    }
    return rectInDestinationWindow;
}

@end
