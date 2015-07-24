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
#import "VTextPostTextView.h"
#import "VEditableTextPostHashtagHelper.h"
#import "VTextPostImageHelper.h"
#import "VContentInputAccessoryView.h"
#import "UIView+AutoLayout.h"
#import "CCHLinkGestureRecognizer.h"

NSString * const kDefaultTextKey = @"defaultText";
static NSString * const kCharacterLimit = @"characterLimit";
static const CGFloat kAccessoryViewHeight = 44.0f;

@interface VEditableTextPostViewController() <UITextViewDelegate, VContentInputAccessoryViewDelegate>

@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) UIButton *overlayButton;

@property (nonatomic, assign) BOOL isShowingPlaceholderText;
@property (nonatomic, assign) NSUInteger characterCountMax;
@property (nonatomic, assign) BOOL hasAppeared;

@property (nonatomic, strong) VEditableTextPostHashtagHelper *hashtagHelper;
@property (nonatomic, strong) VTextPostImageHelper *imageHelper;
@property (nonatomic, assign) UIImage *originalImage;

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
    [self.view insertSubview:self.overlayButton belowSubview:self.textView];
    [self.view v_addFitToParentConstraintsToSubview:self.overlayButton];
    [self.overlayButton addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.hashtagHelper = [[VEditableTextPostHashtagHelper alloc] init];
    self.imageHelper = [[VTextPostImageHelper alloc] init];
    
    self.placeholderText = [self.dependencyManager stringForKey:kDefaultTextKey];
    self.characterCountMax = [self.dependencyManager numberForKey:kCharacterLimit].integerValue;
    [self showPlaceholderText];
    
    self.textView.userInteractionEnabled = YES;
    self.textView.editable = YES;
    self.textView.selectable = YES;
    
    CGRect accessoryFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kAccessoryViewHeight );
    VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:accessoryFrame];
    inputAccessoryView.textInputView = self.textView;
    inputAccessoryView.maxCharacterLength = self.characterCountMax;
    inputAccessoryView.delegate = self;
    inputAccessoryView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.textView.inputAccessoryView = inputAccessoryView;
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
    return self.isShowingPlaceholderText ? @"" : self.textView.text;
}

- (BOOL)addHashtag:(NSString *)hashtagText
{
    if ( hashtagText.length == 0 )
    {
        return NO;
    }
    
    NSUInteger lengthWithAddedHashtag = self.text.length + hashtagText.length;
    BOOL lengthWillBeWithinMaximum = lengthWithAddedHashtag < self.characterCountMax;;
    if ( !lengthWillBeWithinMaximum )
    {
        return NO;
    }
    
    const BOOL didAdd = [self.hashtagHelper addHashtag:hashtagText];
    if ( didAdd )
    {
        [self addHashtagToText:hashtagText];
    }
    
    return didAdd;
}

- (BOOL)removeHashtag:(NSString *)hashtagText
{
    if ( hashtagText.length == 0 )
    {
        return NO;
    }
    
    const BOOL didRemove = [self.hashtagHelper removeHashtag:hashtagText];
    if ( didRemove && ![self.hashtagHelper.collectedHashtagsRemoved containsObject:hashtagText] )
    {
        [self removeHashtagFromText:hashtagText];
    }
    
    return didRemove;
}

- (void)removeHashtagFromText:(NSString *)hashtag
{
    NSString *hashtagTextWithHashMark = [VHashTags stringWithPrependedHashmarkFromString:hashtag];
    NSRange rangeOfHashtag = [self.text rangeOfString:hashtagTextWithHashMark];
    
    if ( rangeOfHashtag.location != NSNotFound )
    {
        self.text = [self.text stringByReplacingOccurrencesOfString:hashtagTextWithHashMark withString:@""];
    }

    [self showPlaceholderText];
    
    [self.delegate textDidUpdate:self.textOutput];
}

- (void)addHashtagToText:(NSString *)hashtag
{
    [self hidePlaceholderText];
    
    NSString *hashtagTextWithHashMark = [VHashTags stringWithPrependedHashmarkFromString:hashtag];
    if ( ![self.text containsString:hashtagTextWithHashMark] )
    {
        self.text = [self.text stringByAppendingString:hashtagTextWithHashMark];
    }
    
    [self.delegate textDidUpdate:self.textOutput];
}

- (void)setText:(NSString *)text
{
    // This keeps the cursor position the same after adding hashtags in superclass
    NSRange selectedRange = self.textView.selectedRange;
    [super setText:text];
    self.textView.selectedRange = selectedRange;
}

- (BOOL)isLastCharacterASpace:(NSString *)string
{
    if ( string.length == 0 )
    {
        return NO;
    }
    return [[string substringFromIndex:string.length-1] isEqualToString:@" "];
}

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

#pragma mark - Placeholder text

- (void)showPlaceholderText
{
    if ( self.text.length == 0 && self.hashtagHelper.embeddedHashtags.count == 0 )
    {
        self.isShowingPlaceholderText = YES;
        NSString *attachment = self.defaultHashtag? [VHashTags stringWithPrependedHashmarkFromString:self.defaultHashtag] : @"";
        self.text = [NSLocalizedString(self.placeholderText, @"") stringByAppendingString:attachment];
        self.textView.alpha = 0.5f;
        
        NSRange cursorPosition = NSMakeRange( self.textView.text.length, 0 );
        if (self.defaultHashtag != nil)
        {
            cursorPosition = NSMakeRange( 0, 0 );
        }
        
        // Set proper cursor position
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.textView.selectedRange = cursorPosition;
        });
    }
}

- (void)hidePlaceholderText
{
    if ( self.isShowingPlaceholderText )
    {
        // Add a space before the default hashtag if there is one
        NSString *replacementString = self.defaultHashtag != nil ? @" " : @"";
        NSString *text = [self.textView.text stringByReplacingOccurrencesOfString:NSLocalizedString(self.placeholderText, @"")
                                                                       withString:replacementString];
        self.text = text;
        self.isShowingPlaceholderText = NO;
        self.textView.alpha = 1.0;
        
        // Move cursor in front of default hashtag
        if (self.defaultHashtag != nil)
        {
            self.textView.selectedRange = NSMakeRange(0, 0);
        }
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.isEditing = YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self hidePlaceholderText];
    
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
    
    [self.delegate textPostViewController:self didDeleteHashtags:[self.hashtagHelper.collectedHashtagsRemoved v_map:removeHashmarkBlock]];
    [self.delegate textPostViewController:self didAddHashtags:[self.hashtagHelper.collectedHashtagsAdded v_map:removeHashmarkBlock]];
    [self.delegate textDidUpdate:self.textOutput];
    
    [self.hashtagHelper resetCollectedHashtagEdits];
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
    
    NSString *textAfter = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ( self.delegate != nil )
    {
        [self.hashtagHelper collectHashtagEditsFromBeforeText:textView.text toAfterText:textAfter];
    }
    
    [self hidePlaceholderText];
    
    return textAfter.length <= self.characterCountMax;
}

#pragma mark - Setting background image and color

- (void)setColor:(UIColor *)color
{
    [super setColor:color];
    
    [self updateBackroundImageAnimated:NO];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    [self setBackgroundImage:backgroundImage animated:NO];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage animated:(BOOL)animated
{
    self.originalImage = backgroundImage;
    
    [self.imageHelper clearCache];
    
    [self updateBackroundImageAnimated:animated];
}

- (void)updateBackroundImageAnimated:(BOOL)animated
{
    [self.imageHelper renderImage:self.originalImage color:self.color completion:^(UIImage *tintedImage, UIColor *color)
     {
         if ( animated )
         {
             [UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
              {
                  self.backgroundImageView.alpha = tintedImage == nil ? 0.0f : 1.0f;
              }
                              completion:^(BOOL finished)
              {
                  if ( self.color == color )
                  {
                      super.backgroundImage = tintedImage;
                  }
              }];
         }
         else
         {
             if ( self.color == color )
             {
                 super.backgroundImage = tintedImage;
             }
         }
     }];
}

#pragma mark - VContentInputAccessoryViewDelegate

- (BOOL)shouldLimitTextEntryForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return YES;
}

- (BOOL)shouldAddHashTagsForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return YES;
}

@end
