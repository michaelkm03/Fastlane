//
//  VKeyboardInputAccessoryView.m
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardInputAccessoryView.h"

// Theme
#import "VThemeManager.h"

@interface VKeyboardInputAccessoryView () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *attachmentsButton;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UITextView *editingTextView;
@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTextViewTopToContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTextViewToBottomContainerConstraint;

@end

@implementation VKeyboardInputAccessoryView

#pragma mark - Factory Methods

+ (VKeyboardInputAccessoryView *)defaultInputAccessoryView
{
    UINib *nibForInputAccessoryView = [UINib nibWithNibName:NSStringFromClass([self class])
                                                     bundle:nil];
    NSArray *nibContents = [nibForInputAccessoryView instantiateWithOwner:nil
                                                                  options:nil];
    
    return [nibContents firstObject];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.editingTextView.delegate = self;
    
    [self.attachmentsButton setImage:[UIImage imageNamed:@"MessageCamera"]
                            forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                          forState:UIControlStateNormal];
    self.editingTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(320.0f, 45.0f);
}

#pragma mark - Property Accessors

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:placeholderText
                                                                           attributes:[self textEntryAttributes]];
}

- (void)setSelectedThumbnail:(UIImage *)selectedThumbnail
{
    _selectedThumbnail = selectedThumbnail;
    
    [self.attachmentsButton setImage:selectedThumbnail
                            forState:UIControlStateNormal];
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _returnKeyType = returnKeyType;
    
    self.editingTextView.returnKeyType = returnKeyType;
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
    self.sendButton.enabled = (textView.text.length == 0) ? NO : YES;
    
    CGFloat desiredHeight = self.verticalSpaceTextViewTopToContainerConstraint.constant + self.verticalSpaceTextViewToBottomContainerConstraint.constant + self.editingTextView.contentSize.height;
    if (self.frame.size.height < desiredHeight)
    {
        if (self.maximumAllowedSize.height <= desiredHeight)
        {
            return;
        }

        [self.delegate keyboardInputAccessoryView:self
                                        wantsSize:CGSizeMake(CGRectGetWidth(self.frame), fminf(desiredHeight, self.maximumAllowedSize.height))];
    }
    else if (CGRectGetHeight(self.frame) > desiredHeight)
    {
        [self.delegate keyboardInputAccessoryView:self
                                        wantsSize:CGSizeMake(CGRectGetWidth(self.frame), fmaxf(desiredHeight, self.intrinsicContentSize.height))];
    }
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

#pragma mark - Convenience

- (NSDictionary *)textEntryAttributes
{
    return @{};
}

@end
