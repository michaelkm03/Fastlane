//
//  VConversationSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationSubViewController.h"
#import "VComposeViewController.h"
#import "UIView+AutoLayout.h"

@interface VConversationSubViewController()
@property (weak, nonatomic) NSLayoutConstraint *bottomConstraint;
@end

@implementation VConversationSubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *composeContainerView = [UIView autoLayoutView];
    composeContainerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:composeContainerView];
    [composeContainerView constrainToHeight:44];
    [composeContainerView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    self.bottomConstraint = [[composeContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:0] firstObject];
    [composeContainerView addSubview:self.composeViewController.view];

    UIView *tableContainerView = [UIView autoLayoutView];
    tableContainerView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tableContainerView];
    [tableContainerView pinToSuperviewEdges:JRTViewPinLeftEdge|JRTViewPinRightEdge inset:0];
    [tableContainerView pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:self.topLayoutGuide];
    [tableContainerView pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofItem:composeContainerView];
    [tableContainerView addSubview:self.conversationTableViewController.view];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardFrameChanged:)
     name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (VComposeViewController *)composeViewController
{
    if(_composeViewController == nil)
    {
        _composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"compose"];
        [self addChildViewController:_composeViewController];
        [_composeViewController didMoveToParentViewController:self];
    }

    return _composeViewController;
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

    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        self.bottomConstraint.constant = -(CGRectGetHeight([[UIScreen mainScreen] bounds])-CGRectGetMinY(keyboardEndFrame));
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end
