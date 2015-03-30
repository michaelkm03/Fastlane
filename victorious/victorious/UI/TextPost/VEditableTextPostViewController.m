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

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isShowingPlaceholderText;

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
    
    self.isShowingPlaceholderText = YES;
    
    self.overlayButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.overlayButton atIndex:0];
    [self.view v_addFitToParentConstraintsToSubview:self.overlayButton];
    [self.overlayButton addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.placeholderText = [self.dependencyManager stringForKey:kDefaultTextKey];
    [self restorePlaceholderText];
    
    self.supplementalHashtags = [[NSMutableSet alloc] init];
    
    self.textView.userInteractionEnabled = YES;
    self.textView.editable = YES;
}

#pragma mark - Supplemental hashtags

- (BOOL)addHashtag:(NSString *)hashtagText
{
    if ( hashtagText.length == 0 )
    {
        return NO;
    }
    
    NSString *hashtagTextWithHashMark = [VHashTags stringWithPrependedHashmarkFromString:hashtagText];
    NSUInteger lengthWithAddedHashtag = self.text.length + hashtagText.length;
    if ( ![self.supplementalHashtags containsObject:hashtagTextWithHashMark] && lengthWithAddedHashtag < self.viewModel.maxTextLength )
    {
        [self clearPlaceholderText];
        [self.supplementalHashtags addObject:hashtagTextWithHashMark];
        NSString *space = [self isLastCharacterASpace:self.text] ? @"" : @" ";
        self.text = [NSString stringWithFormat:@"%@%@%@", self.text, space, hashtagTextWithHashMark];
        return YES;
    }
    
    return NO;
}

- (BOOL)removeHashtag:(NSString *)hashtagText
{
    if ( hashtagText.length == 0 )
    {
        return NO;
    }
    
    NSString *hashtagTextWithHashMark = [VHashTags stringWithPrependedHashmarkFromString:hashtagText];
    if ( [self.supplementalHashtags containsObject:hashtagTextWithHashMark] )
    {
        [self.supplementalHashtags removeObject:hashtagTextWithHashMark];
        self.text = [self.text stringByReplacingOccurrencesOfString:hashtagTextWithHashMark withString:@""];
        if ( [self isLastCharacterASpace:self.text] )
        {
            self.text = [self.text substringToIndex:self.text.length-1];
        }
        return YES;
    }
    
    return NO;
}

- (NSArray *)deletedHastagsFromTextBefore:(NSString *)textBefore textAfter:(NSString *)textAfter
{
    if ( textBefore.length > 0 )
    {
        NSArray *hashtagsBefore = [VHashTags getHashTags:textBefore includeHashMark:YES];
        NSArray *hashtagsAfter = [VHashTags getHashTags:textAfter includeHashMark:YES];
        NSPredicate *filterPrediate = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                       {
                                           return ![hashtagsAfter containsObject:hashtag];
                                       }];
        return [hashtagsBefore filteredArrayUsingPredicate:filterPrediate];
    }
    return @[];
}

- (BOOL)isLastCharacterASpace:(NSString *)string
{
    if ( string.length == 0 )
    {
        return NO;
    }
    return [[string substringFromIndex:string.length-1] isEqualToString:@" "];
}

#pragma mark - Placeholder text

- (void)clearPlaceholderText
{
    if ( self.isShowingPlaceholderText )
    {
        self.isShowingPlaceholderText = NO;
        self.text = @"";
    }
}

- (void)restorePlaceholderText
{
    if ( self.supplementalHashtags.count == 0 && self.text.length == 0 )
    {
        self.text = self.placeholderText;
        self.isShowingPlaceholderText = YES;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self clearPlaceholderText];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.text = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self restorePlaceholderText];
    [textView resignFirstResponder];
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
        NSString *textAfterDeletion = [textView.text stringByReplacingCharactersInRange:range withString:@""];
        NSArray *deletedHashtags = [self deletedHastagsFromTextBefore:textView.text textAfter:textAfterDeletion];
        if ( deletedHashtags.count > 0 )
        {
            NSArray *deletedHashtagsWithoutHashmarks = [deletedHashtags v_map:^NSString *(NSString *string)
                                                        {
                                                            return [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
                                                        }];
            [deletedHashtags enumerateObjectsUsingBlock:^(NSString *hashtag, NSUInteger idx, BOOL *stop)
            {
                [self.supplementalHashtags removeObject:hashtag];
            }];
            [self.delegate textPostViewController:self
                                didDeleteHashtags:deletedHashtagsWithoutHashmarks];
        }
    }
    
    return textView.text.length + text.length < self.viewModel.maxTextLength;
}

#pragma mark - Actions

- (void)overlayButtonTapped:(UIButton *)sender
{
    [self.textView resignFirstResponder];
}

@end
