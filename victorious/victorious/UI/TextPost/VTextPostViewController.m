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

static const CGFloat kTextLineHeight = 35.0f;
static const CGFloat kTextBaselineOffsetMultiplier = 0.371f;
static const NSUInteger kMaxTextLength = 200;

@interface VTextPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;
@property (nonatomic, weak) IBOutlet VTextPostTextView *textView;
@property (nonatomic, weak) IBOutlet VTextPostTextView *hashtagTextView;

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
    
    self.text = @"Enter your text!";
    self.supplementaryHashtagText = @"";
    
    self.textView.clipsToBounds = NO;
    [self.textView addSubview:self.hashtagTextView];
}

- (void)setSupplementaryHashtagText:(NSString *)supplementaryHashtagText
{
    _supplementaryHashtagText = supplementaryHashtagText;
    
    const BOOL wasSelectable = self.hashtagTextView.selectable;
    self.hashtagTextView.selectable = YES; ///< UITextView's attributedString property cannot be read unless this is set to YES
    
    NSDictionary *attribtues = [self hashtagTextAttributesWithDependencyManager:self.dependencyManager];
    self.hashtagTextView.attributedText = [[NSAttributedString alloc] initWithString:supplementaryHashtagText
                                                                          attributes:attribtues];
    [self.hashtagTextView sizeToFit];

    self.hashtagTextView.selectable = wasSelectable;
    
    self.hashtagTextView.hidden = supplementaryHashtagText.length == 0;
    
    [self updateTextBackground];
    [self updateHashtagPostiion];
}

- (void)updateHashtagPostiion
{
    NSValue *lastLineFrameValueObject = self.textView.backgroundFrames.lastObject;
    
    CGRect hashtagTextViewFrame = self.hashtagTextView.frame;
    CGRect lastLineFrame = [lastLineFrameValueObject CGRectValue];
    if ( CGRectGetWidth(lastLineFrame) < CGRectGetWidth(self.textView.frame) - CGRectGetWidth(self.hashtagTextView.frame) )
    {
        // End of last line
        hashtagTextViewFrame.origin.x = CGRectGetMaxX( lastLineFrame ) + 4;
        hashtagTextViewFrame.origin.y = CGRectGetMinY( lastLineFrame ) - 13;
    }
    else
    {
        // New line
        hashtagTextViewFrame.origin.x = CGRectGetMinX( lastLineFrame );
        hashtagTextViewFrame.origin.y = CGRectGetMaxY( lastLineFrame ) - 10
        ;
    }
    self.hashtagTextView.frame = hashtagTextViewFrame;
    [self.hashtagTextView setNeedsLayout];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSDictionary *attributes = [self textAttributesWithDependencyManager:self.dependencyManager];
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    [self updateTextBackground];
    [self updateHashtagPostiion];
}

- (void)updateTextBackground
{
    NSDictionary *attributes = [self textAttributesWithDependencyManager:self.dependencyManager];
    
    for ( VTextPostTextView *textView in @[ self.textView, self.hashtagTextView ] )
    {
        
        NSMutableArray *backgroundFrames = [[NSMutableArray alloc] init];
        [textView layoutIfNeeded];
        NSArray *textLines = [self.textLayoutHelper textLinesFromText:textView.attributedText.string
                                                       withAttributes:attributes
                                                             maxWidth:CGRectGetWidth(textView.frame)];
        
        CGFloat offset = kTextBaselineOffsetMultiplier * kTextLineHeight;
        NSUInteger y = 0;
        for ( NSString *line in textLines )
        {
            CGSize size = [line sizeWithAttributes:attributes];
            CGFloat width = [line isEqual:textLines.lastObject] ? size.width : CGRectGetWidth(textView.frame);
            CGRect rect = CGRectMake( 0, offset + (y++) * (size.height + 2), width + 6, size.height);
            [backgroundFrames addObject:[NSValue valueWithCGRect:rect]];
        }
        
        textView.backgroundFrameColor = [UIColor whiteColor];
        textView.backgroundFrames = [NSArray arrayWithArray:backgroundFrames];
    }
}

#pragma mark - Text Attributes

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{ NSFontAttributeName: [dependencyManager fontForKey:@"font.heading2"],
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.text.content"],
              NSParagraphStyleAttributeName: [self paragraphStyle] };
}

- (NSDictionary *)hashtagTextAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{ NSFontAttributeName: [dependencyManager fontForKey:@"font.heading2"],
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.link"],
              NSParagraphStyleAttributeName: [self paragraphStyle] };
}

- (NSParagraphStyle *)paragraphStyle
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = kTextLineHeight;
    return paragraphStyle;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextBackground];
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
    
    return textView.text.length + text.length < kMaxTextLength;
}

@end
