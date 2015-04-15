//
//  VEditCommentViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEditCommentViewController.h"
#import "VComment.h"
#import "VThemeManager.h"
#import "VObjectManager+Comment.h"
#import "VAlertController.h"
#import "VUserTaggingTextStorage.h"
#import "VInlineSearchTableViewController.h"
#import "UIView+AutoLayout.h"

static const NSInteger kCharacterLimit = 255;
static const CGFloat kTextViewInsetsHorizontal  = 15.0f;
static const CGFloat kTextViewInsetsVertical    = 18.0f;
static const CGFloat kTextViewToViewRatioMax    =  0.4f;
static const CGFloat kSearchTableAnimationDuration = 0.3f;

@implementation VCommentTextView

- (void)paste:(id)sender
{
    [super paste:sender];
    
    NSLog( @"PASTE" );
}

@end

@interface VEditCommentViewController() <UITextViewDelegate, VUserTaggingTextStorageDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *modalContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewVerticalAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonBottomConstraint;
@property (nonatomic, strong) UITextView *editTextView;
@property (nonatomic, strong) VUserTaggingTextStorage *textStorage;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isDismissing;
@property (nonatomic, strong) UIViewController *searchViewController;

@property (strong, nonatomic) VComment *comment;

@end

@implementation VEditCommentViewController

+ (VEditCommentViewController *)instantiateFromStoryboardWithComment:(VComment *)comment
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EditComment" bundle:nil];
    VEditCommentViewController *viewController = (VEditCommentViewController *)[storyboard instantiateInitialViewController];
    viewController.comment = comment;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.modalContainer.layer.cornerRadius = 2.0f;
    self.modalContainer.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    self.modalContainer.layer.borderWidth = 1.0f;
    
    UIFont *defaultFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    
    self.textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:nil defaultFont:defaultFont taggingDelegate:self];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    self.editTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    self.editTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.editTextView.font = defaultFont;
    self.editTextView.returnKeyType = UIReturnKeyDone;
    self.editTextView.delegate = self;
    self.editTextView.text = self.comment.text;
    self.editTextView.textContainerInset = UIEdgeInsetsMake( kTextViewInsetsVertical,
                                                            kTextViewInsetsHorizontal,
                                                            kTextViewInsetsVertical,
                                                            kTextViewInsetsHorizontal );
    
    [self.modalContainer addSubview:self.editTextView];
    [self.modalContainer v_addFitToParentConstraintsToSubview:self.editTextView];
    
    self.textStorage.textView = self.editTextView;
    
    [self updateSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.editTextView becomeFirstResponder];
    
    [self updateSize];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setButtonsVisible:NO delay:0.0f];
    
    if ( self.searchViewController )
    {
        [self animateTableDisappearance];
    }
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateSize
{
    CGSize size = [self.editTextView sizeThatFits:CGSizeMake( CGRectGetWidth(self.editTextView.frame), CGFLOAT_MAX )];
    size.height = MIN( size.height, CGRectGetHeight( self.view.frame ) * kTextViewToViewRatioMax );
    
    [UIView animateWithDuration:0.35f delay:0.0f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.4f
                        options:kNilOptions animations:^void
     {
         self.modalContainerHeightConstraint.constant = size.height;
         
         // Animates this element
         [self.modalContainer layoutIfNeeded];

         // Animates subviews, specifically the attached confirm/cancel buttons
         [self.view layoutIfNeeded];
         
     }
                     completion:nil];
}

- (void)dismiss
{
    if ( self.isDismissing )
    {
        return;
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateCommentText:(NSString *)text
{
    return text != nil && text.length > 0;
}

#pragma mark - IBActions

- (IBAction)onBackgroundTapped:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelEditComment];
    
    [self dismiss];
    self.isDismissing = YES;
}

- (IBAction)onConfirm:(id)sender
{
    self.comment.text = [self.textStorage databaseFormattedString];
    
    [[VObjectManager sharedManager] editComment:self.comment
                                   successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCompleteEditComment];
     }
                                      failBlock:^(NSOperation *operation, NSError *error)
     {
         NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventEditCommentDidFail parameters:params];
         
         VLog( @"Comment edit failed: %@", error.localizedDescription );
     }];
    
    if ( self.delegate != nil )
    {
        [self.delegate didFinishEditingComment:self.comment];
    }
    else
    {
        [self dismiss];
    }
    self.isDismissing = YES;
}

- (IBAction)onCancel:(id)sender
{
    // Tracking
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelEditComment];
    
    [self dismiss];
}

#pragma mark - Button animations

- (void)setButtonsVisible:(BOOL)visible delay:(NSTimeInterval)delay
{
    if ( visible )
    {
        self.buttonCancel.hidden = NO;
        self.buttonConfirm.hidden = NO;
        self.buttonCancel.alpha = 0.0f;
        self.buttonConfirm.alpha = 0.0f;
    }
    
    [UIView animateWithDuration:0.3f delay:delay options:kNilOptions animations:^
    {
        self.buttonCancel.alpha = visible ? 1.0f : 0.0f;
        self.buttonConfirm.alpha = visible ? 1.0f : 0.0f;
    }
                     completion:^(BOOL finished)
     {
         if ( !visible )
         {
             self.buttonCancel.hidden = YES;
             self.buttonConfirm.hidden = YES;
         }
    }];
}

#pragma mark - VUserTaggingTextStorageDelegate

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToShowViewController:(UIViewController *)viewController
{
    self.searchViewController = viewController;
    [UIView animateWithDuration:kSearchTableAnimationDuration animations:^{
       
        self.textViewVerticalAlignmentConstraint.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [viewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [viewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        viewController.view.layer.cornerRadius = 2;
        [viewController.view setClipsToBounds:YES];
        [viewController.view setFrame:CGRectZero];
        [viewController.view setCenter:self.modalContainer.center];
        [self.view addSubview:viewController.view];
        NSDictionary *metrics = @{@"spacing":@(kTextViewInsetsHorizontal), @"height":@(kSearchTableDesiredMinimumHeight)};
        NSDictionary *views = @{@"view":viewController.view, @"search":self.modalContainer};
        
        [UIView animateWithDuration:kSearchTableAnimationDuration animations:^{
           
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[view(>=height)]-spacing-[search]" options:0 metrics:metrics views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-spacing-[view]-spacing-|" options:0 metrics:metrics views:views]];
            
        }];
        
    }];
    
}

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToDismissViewController:(UIViewController *)viewController
{
    [self animateTableDisappearance];
}

- (void)animateTableDisappearance
{
    [UIView animateWithDuration:kSearchTableAnimationDuration animations:^{
        
        self.textViewVerticalAlignmentConstraint.constant = self.keyboardHeight * 0.5f;
        [self.searchViewController.view setAlpha:0.0];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
       
        [self.searchViewController.view removeFromSuperview];
        [self.searchViewController.view setAlpha:1.0];
        self.searchViewController = nil;
        
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    // As in other comment entry sections of the app, we just disable the confirm button
    // if the comment text is invalid
    self.buttonConfirm.enabled = [self validateCommentText:textView.text];
    
    [self updateSize];
}

- (NSInteger)characterLimit
{
    return kCharacterLimit;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] )
    {
        if ( [self validateCommentText:textView.text] )
        {
            [self onConfirm:nil];
        }
        return NO;
    }
    
    return [textView.text stringByReplacingCharactersInRange:range withString:text].length <= (NSUInteger)self.characterLimit;
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat height = CGRectGetHeight( [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] );
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.keyboardHeight = height;
    self.cancelButtonBottomConstraint.constant = height;
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
     {
         self.textViewVerticalAlignmentConstraint.constant = height * 0.5f;
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         [self setButtonsVisible:YES delay:0.4f];
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
     {
         self.textViewVerticalAlignmentConstraint.constant = 0.0f;
         [self.view layoutIfNeeded];
     }
                     completion:nil];
}

@end
