//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentsContainerViewController.h"
#import "VCommentsTableViewController.h"
#import "VKeyboardBarViewController.h"
#import "VSequence.h"
#import "VUser.h"
#import "VConstants.h"
#import "VObjectManager+Comment.h"
#import "UIView+VFrameManipulation.h"
#import "UIImageView+Blurring.h"

@interface VCommentsContainerViewController() <VCommentsTableViewControllerDelegate>
@property (strong, nonatomic) UIImageView* backgroundImage;
@end

@implementation VCommentsContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)commentsContainerView
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCommentsContainerViewController* commentsContainerViewController = (VCommentsContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kCommentsContainerStoryboardID];

    return commentsContainerViewController;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImageView setLightBlurredImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                                    placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
    
    [self.view insertSubview:backgroundImageView belowSubview:self.keyboardBarViewController.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (animated)
    {
        __block CGFloat originalKeyboardY = self.keyboardBarViewController.view.frame.origin.y;
        __block CGFloat originalConvertationX = self.conversationTableViewController.view.frame.origin.y;
        [self.conversationTableViewController.view setXOrigin:self.view.frame.size.width];
        [self.keyboardBarViewController.view setYOrigin:self.view.frame.size.height];
        [UIView animateWithDuration:.5f
                         animations:^{
                             [self.conversationTableViewController.view setXOrigin:originalConvertationX];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.5f
                                              animations:^{
                                                  [self.keyboardBarViewController.view setYOrigin:originalKeyboardY];
                                              }];
                         }];
    }
}

- (UITableViewController *)conversationTableViewController
{
    if(_conversationTableViewController == nil)
    {
        VCommentsTableViewController *streamsCommentsController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
        streamsCommentsController.delegate = self;
        streamsCommentsController.sequence = self.sequence;
//        streamsCommentsController.keyboardBarViewController = self.keyboardBarViewController;
        self.keyboardBarViewController.delegate = streamsCommentsController;
        [self addChildViewController:streamsCommentsController];
        [streamsCommentsController didMoveToParentViewController:self];
        _conversationTableViewController = streamsCommentsController;
    }

    return _conversationTableViewController;
}

//TODO: this is causing issues.  Need to circle back when variable comment height is finished
//- (void)viewDidAppear:(BOOL)animated
//{
//    self.showKeyboard = YES;
//    [super viewDidAppear:animated];
//}

#pragma mark - VCommentsTableViewControllerDelegate

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user
{
    self.keyboardBarViewController.textField.text = [NSString stringWithFormat:@"@%@ ", user.name];
    [self.keyboardBarViewController.textField becomeFirstResponder];
}

@end
