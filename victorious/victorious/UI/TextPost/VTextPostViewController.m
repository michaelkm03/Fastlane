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
#import "NSArray+VMap.h"

@interface VTextPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *overlayButton;

@property (nonatomic, strong) IBOutlet VTextPostViewModel *viewModel;
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
    
    [self updateTextView];
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

#pragma mark - Supplemental hashtags

- (void)addHashtag:(NSString *)hashtagText
{
    if ( hashtagText.length == 0 )
    {
        return;
    }
    
    NSString *hashtagTextWithHashMark = [VHashTags stringWithPrependedHashmarkFromString:hashtagText];
    if ( ![self.supplementalHashtags containsObject:hashtagTextWithHashMark] )
    {
        [self.supplementalHashtags addObject:hashtagTextWithHashMark];
        self.text = [NSString stringWithFormat:@"%@ %@", self.text, hashtagTextWithHashMark];
    }
}

- (void)removeHashtag:(NSString *)hashtagText
{
    if ( hashtagText.length == 0 )
    {
        return;
    }
    
    NSString *hashtagTextWithHashMark = [VHashTags stringWithPrependedHashmarkFromString:hashtagText];
    if ( [self.supplementalHashtags containsObject:hashtagTextWithHashMark] )
    {
        [self.supplementalHashtags removeObject:hashtagTextWithHashMark];
        self.text = [self.text stringByReplacingOccurrencesOfString:hashtagTextWithHashMark withString:@""];
    }
}

- (NSArray *)deletedHastagsFromTextView:(UITextView *)textView inRange:(NSRange)range
{
    NSString *deletedText = [textView.text substringWithRange:range];
    if ( deletedText.length > 0 )
    {
        NSArray *hashtagsBefore = [VHashTags getHashTags:textView.text includeHashMark:YES];
        NSString *textAfterDeletion = [textView.text stringByReplacingOccurrencesOfString:deletedText withString:@""];
        NSArray *hashtagsAfter = [VHashTags getHashTags:textAfterDeletion includeHashMark:YES];
        NSPredicate *filterPrediate = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                       {
                                           return ![hashtagsAfter containsObject:hashtag];
                                       }];
        return [hashtagsBefore filteredArrayUsingPredicate:filterPrediate];
    }
    return @[];
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
    NSDictionary *attributes = [self.viewModel textAttributesWithDependencyManager:self.dependencyManager];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_text attributes:attributes];
    
    NSArray *hashtagRanges = [VHashTags detectHashTags:_text];
    NSDictionary *hashtagAttributes = [self.viewModel hashtagTextAttributesWithDependencyManager:self.dependencyManager];
    [VHashTags formatHashTagsInString:attributedText withTagRanges:hashtagRanges attributes:hashtagAttributes];
    
    NSArray *hashtagCalloutRanges = [VHashTags detectHashTags:_text includeHashSymbol:YES];
    
    [self.textLayoutHelper addWordPaddingWithVaule:self.viewModel.calloutWordPadding
                                toAttributedString:attributedText
                                 withCalloutRanges:hashtagCalloutRanges];
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    
    [self.textLayoutHelper updateTextViewBackground:self.textView calloutRanges:hashtagCalloutRanges];
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
    
    if ( self.delegate != nil )
    {
        NSArray *deletedHashtags = [self deletedHastagsFromTextView:textView inRange:range];
        if ( deletedHashtags.count > 0 )
        {
            NSArray *deletedHashtagsWithoutHashmarks = [deletedHashtags v_map:^NSString *(NSString *string)
            {
                return [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
            }];
            [self.delegate textPostViewController:self didDeleteHashtags:deletedHashtagsWithoutHashmarks];
        }
    }
    
    return textView.text.length + text.length < self.viewModel.maxTextLength;
}

@end
