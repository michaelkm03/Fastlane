//
//  VMemeWorkspaceToolViewController.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextToolViewController.h"

@interface VTextToolViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSArray *centerVerticalAlignmentConstraints;
@property (nonatomic, strong) NSArray *bottomVerticalAlignmentConstraints;

@property (weak, nonatomic) IBOutlet UIImageView *renderedTextImagePreviewView;

@property (nonatomic, strong) NSOperationQueue *textRenderingQueue;
@property (nonatomic, strong) dispatch_queue_t searialTextRenderingQueue;

@end

@implementation VTextToolViewController

+ (instancetype)textToolViewController
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace"
                                                                  bundle:nil];
    return [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

#pragma mark - UIViewController
#pragma mark Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searialTextRenderingQueue = dispatch_queue_create("com.victorious.textToolRenderingQueue", DISPATCH_QUEUE_SERIAL);
    self.textRenderingQueue = [[NSOperationQueue alloc] init];
    self.textRenderingQueue.maxConcurrentOperationCount = 1;
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:@"TYPE YO MEME"
                                                                       attributes:[[self textType] attributes]];
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.scrollEnabled = NO;
    
    UITapGestureRecognizer *tapToEditGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(startEditing:)];
    [self.view addGestureRecognizer:tapToEditGesture];
}

#pragma mark - Property Accessors

- (UIImage *)renderedImage
{
    return self.renderedTextImagePreviewView.image;
}

- (void)setTextType:(VTextTypeTool *)textType
{
    if (_textType == textType)
    {
        return;
    }
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:self.textView.text
                                                                       attributes:[textType attributes]];
    
    if (_textType.verticalAlignment != textType.verticalAlignment)
    {
        [self.centerVerticalAlignmentConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
         {
             [self.view removeConstraint:constraint];
         }];
        [self.bottomVerticalAlignmentConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
         {
             [self.view removeConstraint:constraint];
         }];
        
        NSDictionary *viewMap = @{@"textView": self.textView};
        
        switch (textType.verticalAlignment)
        {
            case VTextTypeVerticalAlignmentCenter:
            {
                NSMutableArray *centerConstraints = [[NSMutableArray alloc] init];
                [centerConstraints addObject:[NSLayoutConstraint constraintWithItem:self.textView
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
                NSMutableArray *bottomConstraints = [[NSMutableArray alloc] init];
                
                NSLayoutConstraint *constraintToTop = [NSLayoutConstraint constraintWithItem:self.textView
                                                                                   attribute:NSLayoutAttributeTop
                                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeTop
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f];
                
                [bottomConstraints addObject:constraintToTop];
                [bottomConstraints addObject:[NSLayoutConstraint constraintWithItem:self.textView
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
        [self.view layoutIfNeeded];
        
    }
    _textType = textType;
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.textRenderingQueue cancelAllOperations];
    [self.textRenderingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^
                                           {
                                               CGFloat scaleFactor = 512 / CGRectGetWidth(self.view.bounds);
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
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^
                                                              {
                                                                  self.renderedTextImagePreviewView.image = renderedImage;
                                                              });
                                           }]];
}

@end
