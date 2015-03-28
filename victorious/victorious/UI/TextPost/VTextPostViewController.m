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

@interface VTextPostViewController ()

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textPostTextView;

@property (nonatomic, strong, readwrite) IBOutlet VTextPostViewModel *viewModel;
@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;

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
    
    [self updateTextView];
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
    
    if ( _text.length == 0 )
    {
        _text = @" ";
    }
    
    [self updateTextView];
}

#pragma mark - public

- (UITextView *)textView
{
    return self.textPostTextView;
}

#pragma mark - Drawing and layout

- (void)updateTextView
{
    if ( self.text == nil )
    {
        return;
    }
    
    NSDictionary *attributes = [self.viewModel textAttributesWithDependencyManager:self.dependencyManager];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_text attributes:attributes];
    
    NSArray *hashtagRanges = [VHashTags detectHashTags:_text];
    NSDictionary *hashtagAttributes = [self.viewModel hashtagTextAttributesWithDependencyManager:self.dependencyManager];
    [VHashTags formatHashTagsInString:attributedText withTagRanges:hashtagRanges attributes:hashtagAttributes];
    
    NSArray *hashtagCalloutRanges = [VHashTags detectHashTags:_text includeHashSymbol:YES];
    
    [self.textLayoutHelper addWordPaddingWithVaule:self.viewModel.calloutWordPadding
                                toAttributedString:attributedText
                                 withCalloutRanges:hashtagCalloutRanges];
    
    self.textPostTextView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    
    [self.textLayoutHelper updateTextViewBackground:self.textPostTextView calloutRanges:hashtagCalloutRanges];
}

@end
