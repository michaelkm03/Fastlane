//
//  VKeyboardBarContainerViewController.m
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"
#import "VConversationViewController.h"
#import "VConstants.h"
#import "VInlineSearchTableViewController.h"

static const CGFloat kKeyboardBarInitialHeight = 55.0f;
static const CGFloat kConversationTableViewInitialHeight = 44.0f;

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

    [self addChildViewController:self.innerViewController];
    self.innerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.innerViewController.view];
    [self.innerViewController didMoveToParentViewController:self];
    
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
                                                                     constant:kKeyboardBarInitialHeight];
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
    
    UIView *view = self.innerViewController.view;
    id topConstraintView = (id)self.topConstraintView ?: self.topLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topConstraintView][view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topConstraintView, view)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:kConversationTableViewInitialHeight]];

    UITableView *tableView = self.innerViewController.tableView;
    tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top,
                                                          tableView.contentInset.left,
                                                          self.keyboardBarHeightConstraint.constant,
                                                          tableView.contentInset.right);
    tableView.scrollIndicatorInsets = tableView.contentInset;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (VKeyboardBarViewController *)keyboardBarViewController
{
    if (_keyboardBarViewController == nil)
    {
        _keyboardBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:kKeyboardBarStoryboardID];
        _keyboardBarViewController.delegate = self;
        _keyboardBarViewController.dependencyManager = self.dependencyManager;
    }

    return _keyboardBarViewController;
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    CGRect keyboardStartFrame;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];

    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardStartFrame];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^
    {
        CGFloat keyboardEndY = CGRectGetMinY(keyboardEndFrame);
        CGFloat keyboardHeight = CGRectGetHeight(self.view.bounds) - keyboardEndY;
        UITableView *tableView = self.innerViewController.tableView;
        CGFloat offset = tableView.contentOffset.y + CGRectGetMinY(keyboardStartFrame) - keyboardEndY;
        CGFloat tableHeight = CGRectGetHeight(tableView.bounds);
        CGFloat contentHeight = tableView.contentSize.height;
        if ( keyboardEndY <= CGRectGetMaxY(self.view.bounds) )
        {
            //Keyboard is overlapping the table, adjust
            self.bottomConstraint.constant = -keyboardHeight;
            if ( contentHeight < tableHeight && keyboardHeight != 0 )
            {
                //Can't just move up content by constraint amount as we don't have enough content to fill out the whole table
                if ( contentHeight > tableHeight - keyboardHeight - self.keyboardBarHeightConstraint.constant )
                {
                    //We need to scroll up to keep the bottom message on screen.
                    offset = contentHeight + keyboardHeight + self.keyboardBarHeightConstraint.constant - tableHeight;
                }
                else
                {
                    //We have so little content that we don't need to scroll up to keep the bottom message onscreen
                    offset = 0.0f;
                }
            }
        }
        else
        {
            //Keyboard is hidden, need to pin the inputView down to the bottom again
            self.bottomConstraint.constant = 0.0f;
            if ( tableHeight >= contentHeight )
            {
                offset = 0.0f;
            }
        }
        tableView.contentOffset = CGPointMake(0.0f, offset);
        [self.view layoutIfNeeded];
    }
                     completion:nil];
}

#pragma mark - VKeyboardBarViewControllerDelegate methods

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text publishParameters:(VPublishParameters *)publishParameters
{
    NSAssert(false, @"keyboardBar:didComposeWithText:mediaURL:mediaExtension: should be overridden in all subclasses of VKeyboardBarContainerViewController!");
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar wouldLikeToBeResizedToHeight:(CGFloat)height
{
    self.keyboardBarHeight = height;
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

- (CGFloat)initialHeightForKeyboardBar:(VKeyboardBarViewController *)keyboardBar
{
    return kKeyboardBarInitialHeight;
}

#pragma mark - VUserTaggingTextStorageDelegate

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToDismissViewController:(UITableViewController *)innerViewController
{
    [innerViewController.view removeFromSuperview];
}

- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToShowViewController:(UIViewController *)innerViewController
{
    // Inline Search layout constraints
    UIView *searchTableView = innerViewController.view;
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
