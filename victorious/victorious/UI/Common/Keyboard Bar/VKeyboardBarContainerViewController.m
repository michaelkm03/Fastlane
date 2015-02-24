//
//  VKeyboardBarContainerViewController.m
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"
#import "VConstants.h"
#import "VInlineSearchTableViewController.h"

@interface VKeyboardBarContainerViewController()

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *keyboardBarHeightConstraint;

@end

@implementation VKeyboardBarContainerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addChildViewController:self.conversationTableViewController];
    self.conversationTableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.conversationTableViewController.view];
    [self.conversationTableViewController didMoveToParentViewController:self];
    
    [self addChildViewController:self.keyboardBarViewController];
    self.keyboardBarViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.keyboardBarViewController.view];
    [self.keyboardBarViewController didMoveToParentViewController:self];

    self.keyboardBarHeightConstraint = [NSLayoutConstraint constraintWithItem:self.keyboardBarViewController.view
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0f
                                                                     constant:55.0f];
    [self.keyboardBarViewController.view addConstraint:self.keyboardBarHeightConstraint];

    UIView *keyboardView = self.keyboardBarViewController.view;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboardView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(keyboardView)]];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:keyboardView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:0];
    [self.view addConstraint:self.bottomConstraint];
    
    UIView *tableView = self.conversationTableViewController.view;
    id topConstraintView = (id)self.topConstraintView ?: self.topLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topConstraintView][tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topConstraintView, tableView, keyboardView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:44.0f]];

    UITableView *conversationTableView = self.conversationTableViewController.tableView;
    conversationTableView.contentInset = UIEdgeInsetsMake(conversationTableView.contentInset.top,
                                                          conversationTableView.contentInset.left,
                                                          self.keyboardBarHeightConstraint.constant,
                                                          conversationTableView.contentInset.right);
    conversationTableView.scrollIndicatorInsets = conversationTableView.contentInset;
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.keyboardBarViewController resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (VKeyboardBarViewController *)keyboardBarViewController
{
    if (_keyboardBarViewController == nil)
    {
        _keyboardBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:kKeyboardBarStoryboardID];
        _keyboardBarViewController.delegate = self;
    }

    return _keyboardBarViewController;
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];

    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    [UIView animateWithDuration:animationDuration delay:0
                        options:(animationCurve << 16) animations:^
    {
        self.bottomConstraint.constant = -(CGRectGetHeight([[UIScreen mainScreen] bounds])-CGRectGetMinY(keyboardEndFrame)-CGRectGetHeight(self.keyboardBarViewController.view.bounds));
        UITableView *tableView = self.conversationTableViewController.tableView;
        tableView.contentOffset = CGPointMake(0, tableView.contentOffset.y - self.bottomConstraint.constant);
        [self.view layoutIfNeeded];
    }
                     completion:nil];
}

#pragma mark - VKeyboardBarViewControllerDelegate methods

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    NSAssert(false, @"keyboardBar:didComposeWithText:mediaURL:mediaExtension: should be overridden in all subclasses of VKeyboardBarContainerViewController!");
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar wouldLikeToBeResizedToHeight:(CGFloat)height
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void)
    {
        self.keyboardBarHeightConstraint.constant = height;
        [self.view layoutIfNeeded];
    }
                     completion:nil];
}

#pragma mark - VUserTaggingTextStorageDelegate

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToDismissViewController:(UITableViewController *)tableViewController
{
    [tableViewController.view removeFromSuperview];
}

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToShowViewController:(UIViewController *)viewController
{
    // Inline Search layout constraints
    UIView *searchTableView = viewController.view;
    UIView *superview = self.view;
    [superview addSubview:searchTableView];
    [searchTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    searchTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    NSDictionary *views = @{@"searchTableView":searchTableView, @"textEntryView":self.keyboardBarViewController.view};
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchTableView(>=height)][textEntryView]"
                                                                      options:0
                                                                      metrics:@{ @"height":@(kSearchTableDesiredMinimumHeight) }
                                                                        views:views]];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[searchTableView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:views]];
}

@end
