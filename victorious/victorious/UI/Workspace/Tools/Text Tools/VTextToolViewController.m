//
//  VTextToolViewController.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextToolViewController.h"
#import "VCapitalizingTextStorage.h"

static const CGFloat kTextRenderingSize = 1024;

@interface VTextToolViewController () <UITextViewDelegate, NSTextStorageDelegate>

@property (nonatomic, strong) UITextView *placeholderTextView;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSArray *textViews;

@property (nonatomic, strong) NSArray *centerVerticalAlignmentConstraints;
@property (nonatomic, strong) NSArray *bottomVerticalAlignmentConstraints;

@property (nonatomic, strong) dispatch_queue_t searialTextRenderingQueue;

@property (nonatomic, strong, readwrite) UIImage *renderedImage;

@property (nonatomic, assign, getter=isSwappingTextTypes) BOOL swappingTextTypes;

@property (nonatomic, strong) VCapitalizingTextStorage *textStorage;

@end

@implementation VTextToolViewController

+ (instancetype)textToolViewController
{
    VTextToolViewController *textToolViewController = [[VTextToolViewController alloc] initWithNibName:nil
                                                                                                bundle:nil];
    textToolViewController.searialTextRenderingQueue = dispatch_queue_create("com.victorious.textToolRenderingQueue", DISPATCH_QUEUE_SERIAL);
    return textToolViewController;
}

#pragma mark - UIViewController
#pragma mark Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];

    self.placeholderTextView =
    ({
        UITextView *placeholderTextView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:nil];
        [self.view addSubview:placeholderTextView];
        placeholderTextView.userInteractionEnabled = NO;
        placeholderTextView;
    });
    self.textView =
    ({
        self.textStorage = [[VCapitalizingTextStorage alloc] init];
        self.textStorage.delegate = self;
        
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [self.textStorage addLayoutManager:layoutManager];
        
        NSTextContainer *textContainer = [[NSTextContainer alloc] init];
        [layoutManager addTextContainer:textContainer];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds
                                                   textContainer:textContainer];
        textView.delegate = self;
        [self.view addSubview:textView];
        textView;
    });
    self.textViews = @[self.placeholderTextView, self.textView];
    [self updateTextAttributesForTextType:self.textType];
    
    [self.textViews enumerateObjectsUsingBlock:^(UITextView *textView, NSUInteger idx, BOOL *stop)
    {
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.scrollEnabled = NO;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.scrollEnabled = NO;
    }];
    
    UITapGestureRecognizer *tapToEditGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(startEditing:)];
    [self.view addGestureRecognizer:tapToEditGesture];
}

#pragma mark - Property Accessors

- (void)setTextType:(VTextTypeTool *)textType
{
    if (_textType == textType)
    {
        return;
    }
    self.renderedImage = nil;
    
    self.swappingTextTypes = YES;
    
    {
        [self updateTextAttributesForTextType:textType];
        if (_textType.verticalAlignment != textType.verticalAlignment)
        {
            [self updateTextViewConstraintsForTextType:textType];
        }
        [self.view layoutIfNeeded];
        _textType = textType;
        
        [self resizeText];
    }
    
    self.swappingTextTypes = NO;
}

- (UIImage *)renderedImage
{
    __block UIImage *renderedImageFromQueue;
    
    if (self.searialTextRenderingQueue != nil)
    {
        dispatch_sync(self.searialTextRenderingQueue, ^
                      {
                          if (_renderedImage == nil)
                          {
                              [self renderText];
                          }
                          renderedImageFromQueue = _renderedImage;
                      });
    }
    
    return renderedImageFromQueue;
}

- (BOOL)userEnteredText
{
    return (self.textStorage.string.length > 0) ? YES : NO;
}

#pragma mark - Target/Action

- (void)startEditing:(UITapGestureRecognizer *)tapGesture
{
    [self.textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    UIFont *styledFont = self.textType.attributes[NSFontAttributeName];
    styledFont = [styledFont fontWithSize:self.textView.font.pointSize];
    
    NSMutableDictionary *sizedAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.textType.attributes];
    sizedAttributes[NSFontAttributeName] = styledFont;
    
    NSRange selectedRange = textView.selectedRange;
    textView.attributedText = [[NSAttributedString alloc] initWithString:self.textView.text
                                                              attributes:sizedAttributes];
    textView.selectedRange = selectedRange;
    
    [self resizeText];
    
    dispatch_async(self.searialTextRenderingQueue, ^
    {
        self.renderedImage = nil;
    });
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.placeholderTextView.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.placeholderTextView.hidden = (self.textStorage.string.length > 0) ? YES : NO;
    
    dispatch_async(self.searialTextRenderingQueue, ^
    {
        [self renderText];
    });
}

#pragma mark - Private Methods

- (void)resizeText
{
    UIFont *prefferedFont = self.textType.attributes[NSFontAttributeName];
    
    while (([self.textView sizeThatFits:self.textView.frame.size]).height > prefferedFont.pointSize)
    {
        self.textView.font = [prefferedFont fontWithSize:self.textView.font.pointSize-1];
    }
    
    while (([self.textView sizeThatFits:self.textView.frame.size]).height < prefferedFont.pointSize)
    {
        self.textView.font = [prefferedFont fontWithSize:self.textView.font.pointSize+1];
    }
}

 /**
 *  Only call this method on searialTextRenderingQueue
 */
- (void)renderText
{
    if (self.textView == nil)
    {
        // Nothing to render
        return;
    }
    
    CGFloat scaleFactor = kTextRenderingSize / CGRectGetWidth(self.view.bounds);
    CGRect scaledRect = CGRectMake(0,
                                   0,
                                   CGRectGetWidth(self.view.bounds) * scaleFactor,
                                   CGRectGetHeight(self.view.bounds) * scaleFactor);
    
    __block UIImage *renderedImage;
    UIGraphicsBeginImageContextWithOptions(scaledRect.size, NO, scaleFactor);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        {
            CGContextScaleCTM(context, scaleFactor, scaleFactor);
            [self.textView.attributedText drawWithRect:self.textView.frame
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
            renderedImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        CGContextRestoreGState(context);
    }
    UIGraphicsEndImageContext();
    
    self.renderedImage = renderedImage;
}

- (void)updateTextAttributesForTextType:(VTextTypeTool *)textType
{
    if (!textType)
    {
        return;
    }
    
    NSString *placeholderText = textType.placeholderText ? textType.placeholderText : @"";
    placeholderText = textType.shouldForceUppercase ? [placeholderText uppercaseString] : placeholderText;
    self.placeholderTextView.attributedText = [[NSAttributedString alloc] initWithString:placeholderText
                                                                              attributes:textType.attributes];

    NSRange fullTextStorageRange = NSMakeRange(0, self.textStorage.string.length);
    self.textStorage.shouldForceUppercase = textType.shouldForceUppercase ? YES : NO;
    [self.textStorage setAttributes:textType.attributes range:fullTextStorageRange];
    self.textView.typingAttributes = textType.attributes;
    [self.textStorage replaceCharactersInRange:fullTextStorageRange
                          withAttributedString:[self.textStorage.unalteredText attributedSubstringFromRange:fullTextStorageRange]];
}

- (void)updateTextViewConstraintsForTextType:(VTextTypeTool *)textType
{
    [self.centerVerticalAlignmentConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
     {
         [self.view removeConstraint:constraint];
     }];
    [self.bottomVerticalAlignmentConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
     {
         [self.view removeConstraint:constraint];
     }];
    
    NSMutableArray *centerConstraints = [[NSMutableArray alloc] init];
    NSMutableArray *bottomConstraints = [[NSMutableArray alloc] init];
    
    [self.textViews enumerateObjectsUsingBlock:^(UITextView *textView, NSUInteger idx, BOOL *stop)
     {
         NSDictionary *viewMap = NSDictionaryOfVariableBindings(textView);
         
         switch (textType.verticalAlignment)
         {
             case VTextTypeVerticalAlignmentCenter:
             {
                 [centerConstraints addObject:[NSLayoutConstraint constraintWithItem:textView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1.0f
                                                                            constant:0.0f]];
                 [centerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[textView]-|"
                                                                                                options:kNilOptions
                                                                                                metrics:nil
                                                                                                  views:viewMap]];
                 [self.view addConstraints:centerConstraints];
                 self.centerVerticalAlignmentConstraints = centerConstraints;
             }
                 break;
             case VTextTypeVerticalAlignmentBottomUp:
             {
                 NSLayoutConstraint *constraintToTop = [NSLayoutConstraint constraintWithItem:textView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                       toItem:self.view
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1.0f
                                                                                     constant:0.0f];
                 [bottomConstraints addObject:constraintToTop];
                 [bottomConstraints addObject:[NSLayoutConstraint constraintWithItem:textView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0f
                                                                            constant:0.0f]];
                 [bottomConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[textView]-|"
                                                                                                options:kNilOptions
                                                                                                metrics:nil
                                                                                                  views:viewMap]];
                 [self.view addConstraints:bottomConstraints];
                 self.bottomVerticalAlignmentConstraints = bottomConstraints;
             }
                 break;
         }
     }];
}

@end
