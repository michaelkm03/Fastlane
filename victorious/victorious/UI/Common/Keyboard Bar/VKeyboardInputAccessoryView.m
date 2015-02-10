//
//  VKeyboardInputAccessoryView.m
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardInputAccessoryView.h"
#import "VUserTaggingTextStorage.h"
#import "VDependencyManager.h"

// Constants
#import "VConstants.h"

// Theme
#import "VThemeManager.h"

const CGFloat VInputAccessoryViewDesiredMinimumHeight = 47.0f;

@interface VKeyboardInputAccessoryView () <UITextViewDelegate>

@property (nonatomic, assign) BOOL selectedMedia;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;

@property (weak, nonatomic) IBOutlet UIImageView *attachmentThumbnail;

@property (nonatomic, weak) IBOutlet UIButton *attachmentsButton;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) UITextView *editingTextView;
@property (nonatomic, weak) IBOutlet UIView *editingTextSuperview;
@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTextViewTopToContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTextViewToBottomContainerConstraint;

@property (weak, nonatomic) VDependencyManager *dependencyManager;

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

- (void)awakeFromNib
{
    self.textStorage = [[VUserTaggingTextStorage alloc] initWithString:nil andDependencyManager:self.dependencyManager textView:nil taggingDelegate:self.delegate];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    UITextView *editingTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    editingTextView.translatesAutoresizingMaskIntoConstraints = NO;
    editingTextView.delegate = self;
    editingTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    editingTextView.font = [UIFont systemFontOfSize:14.0f];
    editingTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    [self.editingTextSuperview addSubview:editingTextView];
    self.editingTextView = editingTextView;
    
    self.textStorage.textView = self.editingTextView;
    
    [self.editingTextSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[editingTextView]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:NSDictionaryOfVariableBindings(editingTextView)]];
    [self.editingTextSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[editingTextView]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:NSDictionaryOfVariableBindings(editingTextView)]];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.sendButton setTitleColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                          forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor lightGrayColor]
                          forState:UIControlStateDisabled];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(320.0f, 45.0f);
}

#pragma mark - Property Accessors

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
    self.attachmentThumbnail.layer.cornerRadius = 2.0f;
    self.attachmentThumbnail.layer.masksToBounds = YES;
    self.attachmentThumbnail.image = selectedThumbnail;

    self.selectedMedia = (selectedThumbnail != nil);
    [self.attachmentsButton setImage:(selectedThumbnail != nil) ? nil : [UIImage imageNamed:@"MessageCamera"]
                            forState:UIControlStateNormal];
    
    [self updateSendButton];
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _returnKeyType = returnKeyType;
    
    self.editingTextView.returnKeyType = returnKeyType;
}

#pragma mark - Public Methods

- (void)startEditing
{
    [self.editingTextView becomeFirstResponder];
}

- (void)clearTextAndResign
{
    self.editingTextView.text = nil;
    self.sendButton.enabled = NO;
    self.attachmentThumbnail.image = nil;
    self.selectedThumbnail = nil;
    self.attachmentsButton.alpha = 1.0f;
    self.selectedMedia = NO;
    [self.attachmentsButton setImage:[UIImage imageNamed:@"MessageCamera"]
                            forState:UIControlStateNormal];
    self.attachmentsButton.selected = NO;

    [self.editingTextView resignFirstResponder];
    [self textViewDidChange:self.editingTextView];
}

#pragma mark - IBActions

- (IBAction)pressedSend:(id)sender
{
    [self.delegate pressedSendOnKeyboardInputAccessoryView:self];
}

- (IBAction)pressedAttachments:(id)sender
{
    [self.delegate pressedAttachmentOnKeyboardInputAccessoryView:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.placeholderLabel.hidden = (textView.text.length == 0) ? NO : YES;
    
    CGFloat desiredHeight = self.verticalSpaceTextViewTopToContainerConstraint.constant + self.verticalSpaceTextViewToBottomContainerConstraint.constant + self.editingTextView.contentSize.height;
    if (CGRectGetHeight(self.frame) < desiredHeight)
    {
        [self.delegate keyboardInputAccessoryView:self
                                        wantsSize:CGSizeMake(CGRectGetWidth(self.frame), roundf(desiredHeight))];
    }
    else if (CGRectGetHeight(self.frame) > desiredHeight)
    {
        [self.delegate keyboardInputAccessoryView:self
                                        wantsSize:CGSizeMake(CGRectGetWidth(self.frame), fmaxf(desiredHeight, self.intrinsicContentSize.height))];
    }
    
    if (textView.text.length == 0)
    {
        if ([self.delegate respondsToSelector:@selector(keyboardInputAccessoryViewDidClearInput:)])
        {
            [self.delegate keyboardInputAccessoryViewDidClearInput:self];
        }
    }
    
    [self updateSendButton];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if (self.returnKeyType == UIReturnKeyDefault)
    {
        return YES;
    }
    
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        if ([self.delegate respondsToSelector:@selector(pressedAlternateReturnKeyonKeyboardInputAccessoryView:)])
        {
            [self.delegate pressedAlternateReturnKeyonKeyboardInputAccessoryView:self];
        }
        
        [self.editingTextView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(keyboardInputAccessoryViewDidEndEditing:)])
    {
        [self.delegate keyboardInputAccessoryViewDidEndEditing:self];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(keyboardInputAccessoryViewDidBeginEditing:)])
    {
        [self.delegate keyboardInputAccessoryViewDidBeginEditing:self];
    }
}

#pragma mark - Convenience

- (NSDictionary *)textEntryAttributes
{
    return @{NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont]};
}

- (void)updateSendButton
{
    self.sendButton.enabled = (self.selectedMedia || (self.composedText.length > 0));
}

- (void)setDelegate:(id<VKeyboardInputAccessoryViewDelegate>)delegate
{
    _delegate = delegate;
    self.textStorage.taggingDelegate = delegate;
    self.textStorage.textView = self.editingTextView;
}

@end

#pragma mark - Input AccessoryView

NSString * const VInputAccessoryViewKeyboardFrameDidChangeNotification = @"com.victorious.VInputAccessoryViewKeyboardFrameDidChangeNotification";

@implementation VInputAccessoryView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview)
    {
        [self.superview removeObserver:self forKeyPath:NSStringFromSelector(@selector(center))];
    }
    
    [newSuperview addObserver:self forKeyPath:NSStringFromSelector(@selector(center)) options:0 context:NULL];
    
    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.superview] && [keyPath isEqualToString:NSStringFromSelector(@selector(center))])
    {
        NSDictionary *userInfo = @{UIKeyboardFrameEndUserInfoKey:[NSValue valueWithCGRect:[object frame]]};
        [[NSNotificationCenter defaultCenter] postNotificationName:VInputAccessoryViewKeyboardFrameDidChangeNotification object:nil userInfo:userInfo];
    }
}

- (void)dealloc
{
    if (self.superview)
    {
        [self.superview removeObserver:self forKeyPath:NSStringFromSelector(@selector(center))];
    }
}

@end
