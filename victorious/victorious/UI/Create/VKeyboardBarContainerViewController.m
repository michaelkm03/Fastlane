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
@property (weak, nonatomic) NSLayoutConstraint *bottomConstraint;
@end

@implementation VKeyboardBarContainerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *keyboardBarContainerView = [[UIView alloc] init];
    keyboardBarContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    keyboardBarContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:keyboardBarContainerView];
    [self addChildViewController:self.keyboardBarViewController];
    self.keyboardBarViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [keyboardBarContainerView addSubview:self.keyboardBarViewController.view];
    [self.keyboardBarViewController didMoveToParentViewController:self];

    UIView *tableContainerView = [[UIView alloc] init];
    tableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    tableContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableContainerView];
    [self addChildViewController:self.conversationTableViewController];
    [tableContainerView addSubview:self.conversationTableViewController.view];
    [self.conversationTableViewController didMoveToParentViewController:self];
    
    [keyboardBarContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[keyboardBarContainerView(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(keyboardBarContainerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keyboardBarContainerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(keyboardBarContainerView)]];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:keyboardBarContainerView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:0];
    [self.view addConstraint:self.bottomConstraint];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableContainerView][keyboardBarContainerView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableContainerView, keyboardBarContainerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableContainerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableContainerView)]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardFrameChanged:)
     name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.showKeyboard)
    {
        [self.keyboardBarViewController.textField becomeFirstResponder];
    }
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.conversationTableViewController.tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);
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

@end
