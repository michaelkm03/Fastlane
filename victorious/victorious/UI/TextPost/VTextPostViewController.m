//
//  VTextPostViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostViewController.h"
#import "VDependencyManager.h"
#import "VTextPostTextView.h"
#import "VTextPostViewModel.h"
#import "VHashTags.h"
#import "victorious-Swift.h" // For VTextPostBackgroundLayout
#import "UIImage+VTint.h"
#import <SDWebImage/UIImage+MultiFormat.h>

static const CGFloat kTintedBackgroundImageAlpha            = 0.375f;
static const CGBlendMode kTintedBackgroundImageBlendMode    = kCGBlendModeLuminosity;

@interface VTextPostViewController ()

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textPostTextView;
@property (nonatomic, strong, readwrite) IBOutlet VTextPostViewModel *viewModel;
@property (nonatomic, strong) VTextBackgroundFrameMaker *textBackgroundFrameMaker;
@property (nonatomic, strong) VTextCalloutFormatter *textCalloutFormatter;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *backgroundImageView;

@end

@implementation VTextPostViewController

#pragma mark - Initializations

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextPostViewController *viewController = [[VTextPostViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textBackgroundFrameMaker = [[VTextBackgroundFrameMaker alloc] init];
    self.textCalloutFormatter = [[VTextCalloutFormatter alloc] init];
    
    self.textView.text = @"";
    self.textView.selectable = NO;
    
    [self updateTextView];
    
    [self updateTextIsSelectable];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ( !self.hasBeenDisplayed )
    {
        [self updateTextView];
        self.hasBeenDisplayed = YES;
    }
}

#pragma mark - View controller lifecycle

- (void)setText:(NSString *)text
{
    if ( [_text isEqualToString:text] )
    {
        return;
    }
    
    _text = text;
    [self updateTextView];
}

- (void)updateTextView
{
    if ( self.text == nil )
    {
        return;
    }
    
    NSDictionary *calloutAttributes = [self.viewModel calloutAttributesWithDependencyManager:self.dependencyManager];
    NSDictionary *attributes = [self.viewModel textAttributesWithDependencyManager:self.dependencyManager];
    NSArray *calloutRanges = [VHashTags detectHashTags:self.text includeHashSymbol:YES];
    [self updateTextView:self.textPostTextView withText:self.text calloutRanges:calloutRanges textAttributes:attributes calloutAttributes:calloutAttributes];
}

#pragma mark - public

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    [self updateBackground];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    [self updateBackground];
}

- (void)setImageURL:(NSURL *)imageURL
{
    if ( _imageURL == imageURL && imageURL != nil )
    {
        return;
    }
    
    _imageURL = imageURL;
    
    [self updateBackground];
}

- (VTextPostTextView *)textView
{
    return self.textPostTextView;
}

- (void)setIsTextSelectable:(BOOL)isTextSelectable
{
    _isTextSelectable = isTextSelectable;
    
    [self updateTextIsSelectable];
}

#pragma mark - Drawing and layout

- (void)updateBackground
{
    if ( self.imageURL != nil )
    {
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ), ^
        {
            UIImage *image = [UIImage sd_imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
            dispatch_async( dispatch_get_main_queue(), ^
                           {
                               const BOOL shouldAnimate = image != nil && self.backgroundImageView.image == nil;
                               [self updateBackgroundWithImage:image];
                               if ( shouldAnimate )
                               {
                                   [self fadeInBackgroundImage];
                               }
                           });
        });
    }
    else if ( self.color != nil || self.backgroundImage != nil )
    {
        [self updateBackgroundWithImage:self.backgroundImage];
    }
}

- (void)updateBackgroundWithImage:(UIImage *)image
{
    if ( image != nil && self.color != nil )
    {
        self.view.backgroundColor = [UIColor blackColor];
        self.backgroundImageView.image = [image v_tintedImageWithColor:self.color
                                                                 alpha:kTintedBackgroundImageAlpha
                                                             blendMode:kTintedBackgroundImageBlendMode];
    }
    else
    {
        self.backgroundImageView.image = image;
    }
    self.view.backgroundColor = self.color ?: [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
}

- (void)fadeInBackgroundImage
{
    self.backgroundImageView.alpha = 0.0f;
    [UIView animateWithDuration:0.15f animations:^
     {
         self.backgroundImageView.alpha = 1.0f;
     }];
}

- (void)updateTextIsSelectable
{
    self.textView.userInteractionEnabled = self.isTextSelectable;
    self.textView.selectable = self.isTextSelectable;
}

- (void)updateTextView:(VTextPostTextView *)textPostTextView
              withText:(NSString *)text
         calloutRanges:(NSArray *)calloutRanges
        textAttributes:(NSDictionary *)textAttributes
     calloutAttributes:(NSDictionary *)calloutAttributes
{
    if ( text == nil )
    {
        return;
    }
    
    const BOOL wasSelected = textPostTextView.selectable;
    textPostTextView.selectable = YES;
    
    textPostTextView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:textAttributes];
    textPostTextView.textContainer.size = CGSizeMake( textPostTextView.bounds.size.width, CGFLOAT_MAX );
    NSRange range = { 0, 1 };
    CGRect characterBounds = [textPostTextView.layoutManager boundingRectForGlyphRange:range inTextContainer:textPostTextView.textContainer];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:textAttributes];
    textPostTextView.attributedText = attributedText;
    
    [self.textCalloutFormatter applyAttributes:calloutAttributes toText:attributedText inCalloutRanges:calloutRanges];
    [self.textCalloutFormatter setKerning:self.viewModel.calloutWordKerning toText:attributedText withCalloutRanges:calloutRanges];
    textPostTextView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    
    NSArray *backgroundFrames = [self.textBackgroundFrameMaker createBackgroundFramesForTextView:self.textView
                                                                                  characterWidth:characterBounds.size.width
                                                                             calloutRangeObjects:calloutRanges];
    self.textView.backgroundFrameColor = self.viewModel.backgroundColor;
    self.textView.backgroundFrames = backgroundFrames;
    
    textPostTextView.selectable = wasSelected;
}

@end
