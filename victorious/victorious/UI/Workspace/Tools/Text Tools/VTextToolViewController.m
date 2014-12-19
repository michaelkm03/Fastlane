//
//  VTextToolViewController.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextToolViewController.h"

static const CGFloat kTextRenderingSize = 1024;

@interface VTextToolViewController () <UITextViewDelegate, NSTextStorageDelegate>

@property (nonatomic, weak) IBOutlet UITextView *placeholderTextView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutletCollection(UITextView) NSArray *textViews;

@property (nonatomic, strong) NSArray *centerVerticalAlignmentConstraints;
@property (nonatomic, strong) NSArray *bottomVerticalAlignmentConstraints;

@property (nonatomic, strong) dispatch_queue_t searialTextRenderingQueue;

@property (nonatomic, strong, readwrite) UIImage *renderedImage;

@property (nonatomic, assign, getter=isSwappingTextTypes) BOOL swappingTextTypes;

@end

@implementation VTextToolViewController

+ (instancetype)textToolViewController
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    return [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.searialTextRenderingQueue = dispatch_queue_create("com.victorious.textToolRenderingQueue", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - UIViewController
#pragma mark Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTextAttributesForTextType:self.textType];
    
    [self.textViews enumerateObjectsUsingBlock:^(UITextView *textView, NSUInteger idx, BOOL *stop)
    {
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.scrollEnabled = NO;
    }];
    
    self.textView.textStorage.delegate = self;
    
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
    
    self.swappingTextTypes = YES;
    {
        [self updateTextAttributesForTextType:textType];
        if (_textType.verticalAlignment != textType.verticalAlignment)
        {
            [self updateTextViewConstraintsForTextType:textType];
        }
        [self.view layoutIfNeeded];
        _textType = textType;
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
    return (self.textView.text.length > 0) ? YES : NO;
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
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
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
    self.placeholderTextView.hidden = (textView.text.length > 0) ? YES : NO;
    
    dispatch_async(self.searialTextRenderingQueue, ^
    {
        [self renderText];
    });
}

#pragma mark - Private Methods

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
    UIGraphicsBeginImageContextWithOptions(scaledRect.size, NO, scaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    __block UIImage *renderedImage;
    CGContextSaveGState(context);
    {
        CGContextScaleCTM(context, scaleFactor, scaleFactor);
        [self.textView.attributedText drawWithRect:self.textView.frame
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil];
        renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    CGContextRestoreGState(context);
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
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:self.textView.text ? self.textView.text : @""
                                                                   attributes:textType.attributes];
    self.textView.typingAttributes = textType.attributes;
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

#pragma mark - NSTextStorageDelegate

// Sent inside -processEditing right before fixing attributes.  Delegates can change the characters or attributes.
- (void)textStorage:(NSTextStorage *)textStorage
 willProcessEditing:(NSTextStorageEditActions)editedMask
              range:(NSRange)editedRange
     changeInLength:(NSInteger)delta
{
    if (self.isSwappingTextTypes)
    {
        return;
    }
    
    if (editedMask & NSTextStorageEditedCharacters)
    {
        if ((delta > 0) && self.textType.shouldForceUppercase)
        {
            [textStorage replaceCharactersInRange:editedRange
                                       withString:[[textStorage.string substringWithRange:editedRange] uppercaseString]];
        }
    }
}

@end
