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
#import "VHashTags.h"

@interface VTextPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *overlayButton;

@property (nonatomic, strong) IBOutlet VTextPostHashtagContraints *hashtagConstraints;
@property (nonatomic, strong) IBOutlet VTextPostConfiguration *configuration;
@property (nonatomic, strong) IBOutlet VTextLayoutHelper *textLayoutHelper;
@property (nonatomic, strong) NSMutableSet *supplementalHashtags;

@end

@implementation VTextPostViewController

#pragma mark - Initializations

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextPostViewController *viewController = [[VTextPostViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    viewController.supplementalHashtags = [[NSMutableSet alloc] init];
    return viewController;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( !self.hasBeenDisplayed )
    {
        [self setDefaultValues];
        self.hasBeenDisplayed = YES;
    }
}

- (void)setDefaultValues
{
    self.text = @"Sample text with #hashtags that will spread to #different lines and count #each one now another #line and still one more #line to come.";
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    if ( _text.length == 0 )
    {
        _text = @" ";
    }
    
    [self updateTextView];
}

- (void)startEditingText
{
    self.editable = YES;
    
    [self.textView becomeFirstResponder];
    self.textView.selectedRange = NSMakeRange( self.textView.text.length, 0 );
    self.overlayButton.hidden = YES;
}

- (void)stopEditingText
{
    [self.textView resignFirstResponder];
    self.overlayButton.hidden = NO;
}

- (void)addHashtag:(NSString *)hashtagText
{
    [self.supplementalHashtags addObject:[VHashTags stringWithPrependedHashmarkFromString:hashtagText]];
    NSLog( @"supplementalHashtags = %@", self.supplementalHashtags );
}

- (NSString *)completedText
{
#warning TODO: Add selected trending hashtags
    return _text;
}

#pragma mark - IBActions

- (IBAction)overlayButtonTapped:(id)sender
{
    if ( self.isEditable )
    {
        [self startEditingText];
    }
}

#pragma mark - Drawing and layout

- (void)updateTextView
{
    NSDictionary *attributes = [self.configuration textAttributesWithDependencyManager:self.dependencyManager];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_text attributes:attributes];;
    
    NSArray *hashtagRanges = [VHashTags detectHashTags:_text];
    NSDictionary *hashtagAttributes = [self.configuration hashtagTextAttributesWithDependencyManager:self.dependencyManager];
    [VHashTags formatHashTagsInString:attributedText withTagRanges:hashtagRanges attributes:hashtagAttributes];
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    
    NSArray *hashtagCalloutRanges = [VHashTags detectHashTags:_text includeHashSymbol:YES];
    [self.textLayoutHelper updateTextViewBackground:self.textView
                                      calloutRanges:hashtagCalloutRanges];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.text = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self stopEditingText];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] )
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return textView.text.length + text.length < self.configuration.maxTextLength;
}

@end
