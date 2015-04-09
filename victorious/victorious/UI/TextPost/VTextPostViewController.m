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
#import "VTextPostViewModel.h"
#import "VHashTags.h"
#import "UIImage+VTint.h"

static const CGFloat kTntedBackgroundImageAlpha = 0.5f;

@interface VTextPostViewController ()

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textPostTextView;
@property (nonatomic, strong, readwrite) IBOutlet VTextPostViewModel *viewModel;
@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

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
    
    self.textView.text = @"";
    self.textView.selectable = NO;
    
    [self updateTextView];
    
    [self updateTextIsSelectable];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self updateTextView];
}

#pragma mark - View controller lifecycle

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSArray *hashtagCalloutRanges = [VHashTags detectHashTags:text includeHashSymbol:YES];
    _text = [self.textLayoutHelper stringByRemovingEmptySpacesInText:text betweenCalloutRanges:hashtagCalloutRanges];
    
    [self updateTextView];
}

- (void)updateTextView
{
    NSDictionary *calloutAttributes = [self.viewModel calloutAttributesWithDependencyManager:self.dependencyManager];
    NSDictionary *attributes = [self.viewModel textAttributesWithDependencyManager:self.dependencyManager];
    [self updateTextView:self.textPostTextView withText:_text textAttributes:attributes calloutAttributes:calloutAttributes];
}

#pragma mark - public

- (VTextPostTextView *)textView
{
    return self.textPostTextView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = [_backgroundImage v_tintedImageWithColor:self.backgroundColor];
    //self.backgroundImageView.image = _backgroundImage;
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if ( _backgroundColor != nil && _backgroundColor == backgroundColor )
    {
        return;
    }
    
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    const BOOL shouldTint = backgroundColor != nil && self.backgroundImage != nil;
    if ( shouldTint )
    {
        self.backgroundImageView.alpha = kTntedBackgroundImageAlpha;
        self.backgroundImageView.image = [self.backgroundImage v_tintedImageWithColor:self.backgroundColor];
    }
    else
    {
        self.backgroundImageView.image = self.backgroundImage;
        self.backgroundImageView.alpha = 1.0f;
    }
}

- (void)setIsTextSelectable:(BOOL)isTextSelectable
{
    _isTextSelectable = isTextSelectable;
    
    [self updateTextIsSelectable];
}

#pragma mark - Drawing and layout

- (void)updateTextIsSelectable
{
    self.textView.userInteractionEnabled = self.isTextSelectable;
    self.textView.selectable = self.isTextSelectable;
}

- (void)updateTextView:(VTextPostTextView *)textPostTextView
              withText:(NSString *)text
        textAttributes:(NSDictionary *)textAttributes
     calloutAttributes:(NSDictionary *)calloutAttributes
{
    if ( text == nil )
    {
        text = @"";
    }
    
    const BOOL wasSelected = textPostTextView.selectable;
    textPostTextView.selectable = YES;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:textAttributes];
    
    NSArray *hashtagRanges = [VHashTags detectHashTags:text];
    
    NSArray *hashtagCalloutRanges = nil;
    if ( calloutAttributes != nil )
    {
        [VHashTags formatHashTagsInString:attributedText withTagRanges:hashtagRanges attributes:calloutAttributes];
        
        hashtagCalloutRanges = [VHashTags detectHashTags:text includeHashSymbol:YES];
        
        [self.textLayoutHelper setAdditionalKerningWithVaule:self.viewModel.calloutWordKerning
                                          toAttributedString:attributedText
                                           withCalloutRanges:hashtagCalloutRanges];
    }
    
    textPostTextView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    [self.textLayoutHelper updateTextViewBackground:textPostTextView calloutRanges:hashtagCalloutRanges];
    
    textPostTextView.selectable = wasSelected;
}

@end
