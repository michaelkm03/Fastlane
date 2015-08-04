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

// Constants
#import "VConstants.h"

// DependencyManager
#import "VDependencyManager.h"

static const NSInteger kCharacterLimit = 255;
static const CGFloat VTextViewTopInsetAddition = 2.0f;
static const CGFloat kAttachmentThumbnailWidth = 35.0f;
static const CGFloat kCommentBarVerticalPaddingToTextView = 10.0f;
static const CGFloat kMaxTextViewHeight = 150.0f;
static const CGFloat kMinTextViewHeight = 40.0f;
static const CGFloat kAttachmentBarHeight = 50.0f;

@interface VKeyboardInputAccessoryView () <UITextViewDelegate>

@property (nonatomic, assign) BOOL selectedMedia;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;
@property (nonatomic, assign) CGSize lastContentSize;

// Views
@property (nonatomic, strong) IBOutlet UIButton *attachmentsButton;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) UITextView *editingTextView;
@property (nonatomic, strong) IBOutlet UIView *editingTextSuperview;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UIButton *imageButton;
@property (nonatomic, strong) IBOutlet UIButton *videoButton;
@property (nonatomic, strong) IBOutlet UIButton *gifButton;
@property (nonatomic, strong) IBOutlet UIButton *clearAttachmentButton;

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
    UINib *nibForInputAccessoryView = [UINib nibWithNibName:NSStringFromClass([self class])
                                                     bundle:nil];
    NSArray *nibContents = [nibForInputAccessoryView instantiateWithOwner:nil
                                                                  options:nil];
    
    VKeyboardInputAccessoryView *accessoryView = [nibContents firstObject];
    
    accessoryView.dependencyManager = dependencyManager;
    
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
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Automation Support
    self.imageButton.accessibilityIdentifier = VAutomationIdentifierCommentBarImageButton;
    self.videoButton.accessibilityIdentifier = VAutomationIdentifierCommentBarVideoButton;
    self.gifButton.accessibilityIdentifier = VAutomationIdentifierCommentBarGIFButton;
    self.sendButton.accessibilityIdentifier = VAutomationIdentifierCommentBarSendButton;
    self.clearAttachmentButton.accessibilityIdentifier = VAutomationIdentifierCommentBarClearButton;
}

- (void)addTextViewToContainer
{
    UIFont *defaultFont = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    self.textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:nil defaultFont:defaultFont taggingDelegate:self.delegate dependencyManager:self.dependencyManager];
    
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.sendButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                          forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor lightGrayColor]
                          forState:UIControlStateDisabled];
}

- (CGSize)intrinsicContentSize
{
    CGFloat editingTextViewPadding = self.editingTextViewTopSpace.constant + self.editingTextViewBottomSpace.constant;
    CGFloat contentSizeHeight = self.editingTextView.contentSize.height;
    CGFloat heightSum = editingTextViewPadding + contentSizeHeight;
    CGSize intrinsicSize = CGSizeMake(CGRectGetWidth(self.bounds), MAX(heightSum, kAttachmentBarHeight));
    return intrinsicSize;
}

- (BOOL)stopEditing
{
    return [self.editingTextView resignFirstResponder];
}

#pragma mark - Property Accessors

- (void)setDelegate:(id<VKeyboardInputAccessoryViewDelegate>)delegate
{
    _delegate = delegate;
    self.textStorage.taggingDelegate = delegate;
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
    self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:placeholderText
                                                                           attributes:[self textEntryAttributes]];
}

- (void)setSelectedThumbnail:(UIImage *)selectedThumbnail
{
    self.attachmentsButton.layer.cornerRadius = 2.0f;
    self.attachmentsButton.layer.masksToBounds = YES;
    self.attachmentsButton.clipsToBounds = YES;
    
    [self.attachmentsButton setBackgroundImage:selectedThumbnail
                                      forState:UIControlStateNormal];
    
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
