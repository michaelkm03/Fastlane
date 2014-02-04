//
//  VKeyboardBarContainerViewController.m
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"
#import "VKeyboardBarViewController.h"
#import "UIView+AutoLayout.h"
#import "VConstants.h"

@interface VKeyboardBarContainerViewController()
@property (weak, nonatomic) NSLayoutConstraint *bottomConstraint;
@end

@implementation VKeyboardBarContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *keyboardBarContainerView = [UIView autoLayoutView];
    keyboardBarContainerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:keyboardBarContainerView];
    [keyboardBarContainerView constrainToHeight:44];
    [keyboardBarContainerView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    self.bottomConstraint = [[keyboardBarContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:0] firstObject];
    [keyboardBarContainerView addSubview:self.keyboardBarViewController.view];

    UIView *tableContainerView = [UIView autoLayoutView];
    tableContainerView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tableContainerView];
    [tableContainerView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    [tableContainerView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];
    [tableContainerView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:keyboardBarContainerView];
    [tableContainerView addSubview:self.conversationTableViewController.view];

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
        [self addChildViewController:_keyboardBarViewController];
        [_keyboardBarViewController didMoveToParentViewController:self];
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

@end
