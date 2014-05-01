//
//  VKeyboardBarContainerViewController.m
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"
#import "VKeyboardBarViewController.h"
#import "VConstants.h"

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

    [self addChildViewController:self.keyboardBarViewController];
    self.keyboardBarViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.keyboardBarViewController.view];
    [self.keyboardBarViewController didMoveToParentViewController:self];

    [self addChildViewController:self.conversationTableViewController];
    self.conversationTableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.conversationTableViewController.view];
    [self.conversationTableViewController didMoveToParentViewController:self];
    
    self.keyboardBarHeightConstraint = [NSLayoutConstraint constraintWithItem:self.keyboardBarViewController.view
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0f
                                                                     constant:47.0f];
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topConstraintView][tableView][keyboardView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topConstraintView, tableView, keyboardView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:44.0f]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (VKeyboardBarViewController *)keyboardBarViewController
{
    if(_keyboardBarViewController == nil)
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
        self.bottomConstraint.constant = -(CGRectGetHeight([[UIScreen mainScreen] bounds])-CGRectGetMinY(keyboardEndFrame));
        [self.view layoutIfNeeded];
    }
                     completion:nil];
}

#pragma mark - VKeyboardBarViewControllerDelegate methods

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL mediaExtension:(NSString *)mediaExtension
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

@end
