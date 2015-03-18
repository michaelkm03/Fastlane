//
//  VTextPostViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostViewController.h"
#import "VTextLayoutHelper.h"
#import "VTextBackgroundView.h"
#import "VDependencyManager.h"

static const CGFloat kTextLineHeight = 35.0f;
static const CGFloat kTextBaselineOffsetMultiplier = 0.371f;
static const NSUInteger kMaxTextLength = 200;

@interface VTextPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet VTextBackgroundView *backgroundView;
@property (nonatomic, strong) UITextView *hashtagTextview;

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
}

- (void)setSupplementaryHashtagText:(NSString *)supplementaryHashtagText
{
    _supplementaryHashtagText = supplementaryHashtagText;
    
    if ( self.hashtagTextview != nil )
    {
        [self.hashtagTextview removeFromSuperview];
        self.hashtagTextview = nil;
    }
    else
    {
        self.hashtagTextview = [[UITextView alloc] init];
        NSDictionary *attribtues = [self hashtagTextAttributesWithDependencyManager:self.dependencyManager];
        self.hashtagTextview.attributedText = [[NSAttributedString alloc] initWithString:supplementaryHashtagText
                                                                              attributes:attribtues];
        [self.hashtagTextview sizeToFit];
        [self.view addSubview:self.hashtagTextview];
    }
    
    [self updateTextBackground];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSDictionary *attributes = [self textAttributesWithDependencyManager:self.dependencyManager];
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    [self updateTextBackground];
}

- (void)updateTextBackground
{
    NSDictionary *attributes = [self textAttributesWithDependencyManager:self.dependencyManager];
    NSMutableArray *backgroundFrames = [[NSMutableArray alloc] init];
    
    for ( UITextView *textView in @[ self.textView, self.supplementaryHashtagText ?: [NSNull null] ] )
    {
        if ( ![textView isKindOfClass:[UITextView class]] )
        {
            continue;
        }
        [textView layoutIfNeeded];
        NSArray *textLines = [self.textLayoutHelper textLinesFromText:textView.attributedText.string
                                                       withAttributes:attributes
                                                             maxWidth:CGRectGetWidth(textView.frame)];
        
        CGFloat offset = kTextBaselineOffsetMultiplier * kTextLineHeight;
        NSUInteger y = 0;
        for ( NSString *line in textLines )
        {
            CGSize size = [line sizeWithAttributes:attributes];
            CGFloat width = [line isEqual:textLines.lastObject] ? size.width : CGRectGetWidth(self.view.frame);
            CGRect rect = CGRectMake( 0, offset + (y++) * (size.height + 2), width, size.height );
            [backgroundFrames addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    self.backgroundView.backgroundFrameColor = [UIColor whiteColor];
    self.backgroundView.backgroundFrames = backgroundFrames;
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
