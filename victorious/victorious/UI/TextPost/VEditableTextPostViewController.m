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
#import "VTextPostTextView.h"

static NSString * const kDefaultTextKey = @"defaultText";

@interface VEditableTextPostViewController() <UITextViewDelegate>

@property (nonatomic, strong) NSMutableSet *supplementalHashtags;
@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) UIButton *overlayButton;

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isShowingPlaceholderText;
@property (nonatomic, assign) BOOL hasAppeared;

@property (nonatomic, strong) NSArray *deletedHashtags;
@property (nonatomic, strong) NSArray *addedHashtags;

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
    [self.view insertSubview:self.overlayButton atIndex:0];
    [self.view v_addFitToParentConstraintsToSubview:self.overlayButton];
    [self.overlayButton addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.supplementalHashtags = [[NSMutableSet alloc] init];
    
    self.textView.userInteractionEnabled = YES;
    self.textView.editable = YES;
    
    self.placeholderText = [self.dependencyManager stringForKey:kDefaultTextKey];
    [self showPlaceholderText];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.delegate textDidUpdate:self.textOutput];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( !self.hasAppeared )
    {
        self.isEditing = YES;
        self.hasAppeared = YES;
    }
}

- (NSString *)textOutput
{
    return self.isShowingPlaceholderText ? @"" : self.text;
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
    if ( ![self.supplementalHashtags containsObject:hashtagTextWithHashMark] &&
         lengthWithAddedHashtag < self.viewModel.maxTextLength &&
         ![self.text containsString:hashtagTextWithHashMark] )
    {
        [self.supplementalHashtags addObject:hashtagTextWithHashMark];
        
        [self hidePlaceholderText];
        
        NSString *space = [self isLastCharacterASpace:self.text] || self.text.length == 0 ? @"" : @" ";
        self.text = [NSString stringWithFormat:@"%@%@%@", self.text, space, hashtagTextWithHashMark];
        
        [self.delegate textDidUpdate:self.textOutput];
        
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
        
        [self showPlaceholderText];
        
        [self.delegate textDidUpdate:self.textOutput];
        
        return YES;
    }
    
    return NO;
}

- (void)getHashtagsAdded:(NSArray **)added deleted:(NSArray **)deleted withBeforeText:(NSString *)beforeText afterText:(NSString *)afterText
{
    NSArray *hashtagsBefore = [VHashTags getHashTags:beforeText includeHashMark:YES];
    NSArray *hashtagsAfter = [VHashTags getHashTags:afterText includeHashMark:YES];
    
    NSPredicate *addedFilter = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                {
                                    return ![hashtagsBefore containsObject:hashtag];
                                }];
    *added = [hashtagsAfter filteredArrayUsingPredicate:addedFilter];
    
    NSPredicate *deletedFilter = [NSPredicate predicateWithBlock:^BOOL(NSString *hashtag, NSDictionary *bindings)
                                  {
                                      return ![hashtagsAfter containsObject:hashtag];
                                  }];
    *deleted = [hashtagsBefore filteredArrayUsingPredicate:deletedFilter];
}

- (BOOL)isLastCharacterASpace:(NSString *)string
{
    if ( string.length == 0 )
    {
        return NO;
    }
    return [[string substringFromIndex:string.length-1] isEqualToString:@" "];
}

- (void)setText:(NSString *)text
{
    // This keeps the cursor position the same after adding hashtags in superclass
    NSRange selectedRange = self.textView.selectedRange;
    [super setText:text];
    self.textView.selectedRange = selectedRange;
}

#pragma mark - Placeholder text

- (void)showPlaceholderText
{
    if ( self.text.length == 0 && self.supplementalHashtags.count == 0 )
    {
        self.isShowingPlaceholderText = YES;
        self.text = self.placeholderText;
        self.textView.alpha = 0.5f;
        self.textView.selectedRange = NSMakeRange( self.textView.text.length, 0 );
    }
}

- (void)hidePlaceholderText
{
    if ( self.isShowingPlaceholderText )
    {
        self.text = @"";
        self.isShowingPlaceholderText = NO;
        self.textView.alpha = 1.0;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.isEditing = YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.text = self.textView.text;
    
    [self updateAddedAndDeletedHashtags];
    
    [self.delegate textDidUpdate:self.textOutput];
}

- (void)updateAddedAndDeletedHashtags
{
    if ( self.delegate == nil )
    {
        return;
    }
    
    NSString *(^removeHashmarkBlock)(NSString *) = ^NSString *(NSString *string)
    {
        return [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    };
    
    if ( self.deletedHashtags.count > 0 )
    {
        NSArray *deletedHashtagsWithoutHashmarks = [self.deletedHashtags v_map:removeHashmarkBlock];
        [self.deletedHashtags enumerateObjectsUsingBlock:^(NSString *hashtag, NSUInteger idx, BOOL *stop)
         {
             [self.supplementalHashtags removeObject:hashtag];
         }];
        [self.delegate textPostViewController:self didDeleteHashtags:deletedHashtagsWithoutHashmarks];
    }
    
    if ( self.addedHashtags.count > 0 )
    {
        [self.delegate textPostViewController:self didAddHashtags:[self.addedHashtags v_map:removeHashmarkBlock]];
    }
    
    self.deletedHashtags = nil;
    self.addedHashtags = nil;
    
    [self.delegate textDidUpdate:self.textOutput];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.isEditing = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] )
    {
        self.isEditing = NO;
        return NO;
    }
    
    if ( self.delegate != nil )
    {
        NSString *textAfter = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSArray *deletedHashtags;
        NSArray *addedHashtags;
        
        [self getHashtagsAdded:&addedHashtags deleted:&deletedHashtags withBeforeText:textView.text afterText:textAfter];
        
        self.deletedHashtags = deletedHashtags;
        self.addedHashtags = addedHashtags;
    }
    
    [self hidePlaceholderText];
    
    return textView.text.length + text.length < self.viewModel.maxTextLength;
}

#pragma mark - Actions

- (void)setIsEditing:(BOOL)isEditing
{
    if ( isEditing == _isEditing )
    {
        return;
    }
    _isEditing = isEditing;
    if ( _isEditing )
    {
        [self.textView becomeFirstResponder];
    }
    else
    {
        [self.textView resignFirstResponder];
        
        [self showPlaceholderText];
    }
}

- (void)overlayButtonTapped:(UIButton *)sender
{
    self.isEditing = !self.isEditing;
}

@end
