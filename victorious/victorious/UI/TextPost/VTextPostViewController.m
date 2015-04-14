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
#import "victorious-Swift.h" // For VTextPostBackgroundLayout

@interface VTextPostViewController ()

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textPostTextView;
@property (nonatomic, strong, readwrite) IBOutlet VTextPostViewModel *viewModel;
@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;

@property (nonatomic, strong) VTextPostBackgroundLayout *textPostBackgroundLayout;

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
    
    self.textPostBackgroundLayout = [[VTextPostBackgroundLayout alloc] init];
    
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

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.view.backgroundColor = color ?: [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
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
    [self updateTextView:self.textPostTextView withText:_text calloutRanges:calloutRanges textAttributes:attributes calloutAttributes:calloutAttributes];
}

#pragma mark - public

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
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:textAttributes];
    [VHashTags formatHashTagsInString:attributedText withTagRanges:calloutRanges attributes:calloutAttributes containsHashmark:YES];
    [self.textLayoutHelper setAdditionalKerningWithVaule:self.viewModel.calloutWordKerning
                                      toAttributedString:attributedText
                                       withCalloutRanges:calloutRanges];
    
    textPostTextView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    [self.textPostBackgroundLayout updateTextViewBackground:self.textView calloutRangeObjects:calloutRanges];
    
    textPostTextView.selectable = wasSelected;
}

@end
