//
//  VEditableTextPostViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditableTextPostViewController.h"
#import "VHashTags.h"
#import "NSArray+VMap.h"
#import "VTextPostViewModel.h"
#import "VDependencyManager.h"
#import "UIView+AutoLayout.h"

static NSString * const kDefaultTextKey = @"defaultText";

@interface VEditableTextPostViewController() <UITextViewDelegate>

@property (nonatomic, strong) NSMutableSet *supplementalHashtags;
@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) UIButton *overlayButton;

@end

@implementation VEditableTextPostViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([VTextPostViewController class]);
    NSBundle *bundle = [NSBundle bundleForClass:[VTextPostViewController class]];
    VEditableTextPostViewController *viewController = [[VEditableTextPostViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.overlayButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.overlayButton];
    [self.view v_addFitToParentConstraintsToSubview:self.overlayButton];
    [self.overlayButton addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderText = [self.dependencyManager stringForKey:kDefaultTextKey];
    self.text = self.placeholderText;
    
    self.supplementalHashtags = [[NSMutableSet alloc] init];
}

#pragma mark -

- (void)startEditingText
{
    [self.textView becomeFirstResponder];
    self.textView.userInteractionEnabled = YES;
    self.textView.editable = YES;
    self.textView.selectedRange = NSMakeRange( self.textView.text.length, 0 );
    self.overlayButton.hidden = YES;
}

- (void)stopEditingText
{
    self.textView.userInteractionEnabled = NO;
    self.textView.editable = NO;
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

#pragma mark - Actions

- (void)overlayButtonTapped:(UIButton *)sender
{
    [self startEditingText];
}

@end
