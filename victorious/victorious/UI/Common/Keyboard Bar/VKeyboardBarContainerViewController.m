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
    
    UIView *tableView = self.conversationTableViewController.view;
    id topConstraintView = (id)self.topConstraintView ?: self.topLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topConstraintView][tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topConstraintView, tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:kConversationTableViewInitialHeight]];

    UITableView *conversationTableView = self.conversationTableViewController.tableView;
    conversationTableView.contentInset = UIEdgeInsetsMake(conversationTableView.contentInset.top,
                                                          conversationTableView.contentInset.left,
                                                          self.keyboardBarHeightConstraint.constant,
                                                          conversationTableView.contentInset.right);
    conversationTableView.scrollIndicatorInsets = conversationTableView.contentInset;
    
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
        UITableView *tableView = self.conversationTableViewController.tableView;
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

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    NSAssert(false, @"keyboardBar:didComposeWithText:mediaURL:mediaExtension: should be overridden in all subclasses of VKeyboardBarContainerViewController!");
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar resizeToHeight:(CGFloat)height
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

- (CGFloat)initialHeightForKeyboardBar:(VKeyboardBarViewController *)keyboardBar  {
    return kKeyboardBarInitialHeight;
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
