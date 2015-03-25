//
//  VTextPostViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostViewController.h"
#import "VTextLayoutHelper.h"
#import "VDependencyManager.h"
#import "VTextPostTextView.h"
#import "VTextPostHashtagContraints.h"
#import "VTextPostConfiguration.h"

@interface VTextPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textView;
@property (nonatomic, weak) IBOutlet VTextPostTextView *hashtagTextView;

@property (nonatomic, strong) IBOutlet VTextPostHashtagContraints *hashtagConstraints;
@property (nonatomic, strong) IBOutlet VTextPostConfiguration *configuration;
@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;

@end

@implementation VTextPostViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextPostViewController *viewController = [[VTextPostViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)startEditingText
{
    [self.textView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.text = @"";
    self.supplementaryHashtagText = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.text = @"What's on your mind?";
    self.supplementaryHashtagText = @"#hashtag";
}

- (void)setSupplementaryHashtagText:(NSString *)supplementaryHashtagText
{
    _supplementaryHashtagText = supplementaryHashtagText;
    if ( _supplementaryHashtagText.length > 0 && [_supplementaryHashtagText rangeOfString:@"#"].location != 0 )
    {
        _supplementaryHashtagText = [NSString stringWithFormat:@"#%@", _supplementaryHashtagText];
    }
    
    const BOOL wasSelectable = self.hashtagTextView.selectable;
    self.hashtagTextView.selectable = YES; ///< UITextView's attributedString property cannot be read unless this is set to YES
    
    NSDictionary *attribtues = [self hashtagTextAttributesWithDependencyManager:self.dependencyManager];
    self.hashtagTextView.attributedText = [[NSAttributedString alloc] initWithString:_supplementaryHashtagText
                                                                          attributes:attribtues];
    
    self.hashtagTextView.selectable = wasSelectable;
    
    self.hashtagTextView.hidden = _supplementaryHashtagText.length == 0;
    
    [self updateTextBackgrounds];
    [self updateHashtagPostiion];
}

- (void)updateHashtagPostiion
{
    CGRect textLastLineFrame = [self.textView.backgroundFrames.lastObject CGRectValue];
    textLastLineFrame.origin.y -= ceil(self.textView.font.pointSize / self.configuration.lineHeightMultipler);
    CGRect hashtagTextFrame = [self.hashtagTextView.backgroundFrames.lastObject CGRectValue];
    
    CGFloat targetLeading = textLastLineFrame.size.width + CGRectGetMinX( self.textView.frame ) + self.configuration.horizontalSpacing;
    CGFloat spaceNeededForHashtagText = CGRectGetWidth( self.textView.frame ) - CGRectGetWidth( hashtagTextFrame );
    if ( targetLeading < spaceNeededForHashtagText )
    {
        self.hashtagConstraints.top.constant = CGRectGetMinY( textLastLineFrame );
        self.hashtagConstraints.leading.constant = targetLeading;
    }
    else
    {
        self.hashtagConstraints.top.constant = CGRectGetMaxY( textLastLineFrame ) + self.configuration.verticalSpacing;
        self.hashtagConstraints.leading.constant = CGRectGetMinX( self.textView.frame );
    }
    [self.view layoutIfNeeded];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    if ( _text.length == 0 )
    {
        _text = @" ";
    }
    
    NSDictionary *attributes = [self textAttributesWithDependencyManager:self.dependencyManager];
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:_text attributes:attributes];
    
    [self updateTextBackgrounds];
    [self updateHashtagPostiion];
}

- (void)updateTextBackgrounds
{
    for ( VTextPostTextView *textView in @[ self.textView, self.hashtagTextView] )
    {
        [self.textLayoutHelper updateTextViewBackground:textView configuraiton:self.configuration];
    }
}

#pragma mark - Text Attributes

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.text.content"],
              NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
}

- (NSDictionary *)hashtagTextAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.link"],
              NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
}

- (NSParagraphStyle *)paragraphStyleWithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = ((CGFloat)font.pointSize) * self.configuration.lineHeightMultipler;
    return paragraphStyle;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextBackgrounds];
    [self updateHashtagPostiion];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] )
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    if ( text.length == 0 )
    {
        self.text = @" ";
        return NO;
    }
    
    return textView.text.length + text.length < self.configuration.maxTextLength;
}

@end
