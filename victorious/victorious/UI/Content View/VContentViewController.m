//
//  VContentViewController.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"
#import "VContentViewController+Images.h"
#import "VContentViewController+Private.h"
#import "VContentViewController+Polls.h"
#import "VContentViewController+Videos.h"

#import "VCommentsContainerViewController.h"

#import "UIImageView+Blurring.h"

#import "VActionBarViewController.h"
#import "VEmotiveBallisticsBarViewController.h"

#import "VContentToStreamAnimator.h"
#import "VContentToCommentAnimator.h"

CGFloat kContentMediaViewOffset = 154;

@import MediaPlayer;

@implementation VContentViewController

+ (VContentViewController *)sharedInstance
{
    static  VContentViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken,
    ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VContentViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kContentViewStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupVideoPlayer];

    for (UIButton* button in self.buttonCollection)
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    }
    self.descriptionLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    [self.remixButton setImage:[self.remixButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.remixButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
    self.activityIndicator.layer.cornerRadius = self.activityIndicator.frame.size.height / 2;
    self.activityIndicator.hidesWhenStopped = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.firstResultView setProgress:0 animated:NO];
    self.firstResultView.isVertical = YES;
    self.firstResultView.hidden = YES;
    self.firstResultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    [self.secondResultView setProgress:0 animated:NO];
    self.secondResultView.isVertical = YES;
    self.secondResultView.hidden = YES;
    self.secondResultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.sequence = self.sequence;
    
    self.orImageView.hidden = ![self.sequence isPoll];

    self.orImageView.center = [self.pollPreviewView convertPoint:self.pollPreviewView.center toView:self.orContainerView];
    
    self.firstPollButton.alpha = 0;
    self.secondPollButton.alpha = 0;
    
    self.actionBarVC = nil;
    
    self.navigationController.delegate = self;
    
    CGRect topActionsFrame = self.topActionsView.frame;
    self.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), CGRectGetMinY(self.mediaView.frame), CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
    
    self.topActionsView.alpha = 0;
    [UIView animateWithDuration:.2f
                     animations:^
     {
         self.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), 0, CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
         self.topActionsView.alpha = 1;
         self.firstPollButton.alpha = 1;
         self.secondPollButton.alpha = 1;
     }
                     completion:^(BOOL finished)
     {
         [self updateActionBar];
     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.navigationController.delegate == self)
    {
        self.navigationController.delegate = nil;
    }
    
    [self.mpController.view removeFromSuperview];
    [self.mpController pause];
    self.mpController = nil;
    
    self.orAnimator = nil;
}

-(VInteractionManager*)interactionManager
{
    if(!_interactionManager)
    {
        _interactionManager = [[VInteractionManager alloc] initWithNode:self.currentNode delegate:self];
    }
    return _interactionManager;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;

    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [self.backgroundImage setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                     placeholderImage:placeholderImage];
    self.descriptionLabel.text = _sequence.name;
    self.currentNode = [sequence firstNode];
}

- (void)setCurrentNode:(VNode *)currentNode
{
    //If you run out of nodes... go to the beginning.
    if (!currentNode)
        _currentNode = [self.sequence firstNode];
    
    //If this node is not for the sequence... Something is wrong, just use the first node and print a warning
    else if (currentNode.sequence != self.sequence)
    {
        VLog(@"Warning: node %@ does not belong in sequence %@", currentNode, self.sequence);
        _currentNode = [self.sequence firstNode];
    }
    else
        _currentNode = currentNode;
    
    _currentAsset = nil; //we changed nodes, so we're not on an asset
    if ([self.currentNode isQuiz])
        [self loadQuiz];
    
    else if ([self.currentNode isPoll])
        [self loadPoll];
    
    else
        [self loadNextAsset];
    
    self.interactionManager.node = currentNode;
}

- (void)setActionBarVC:(VActionBarViewController *)actionBarVC
{
    [_actionBarVC removeFromParentViewController];
    [_actionBarVC.view removeFromSuperview];
    _actionBarVC = actionBarVC;
    
    if(actionBarVC)
    {
        [self addChildViewController:actionBarVC];
        [actionBarVC didMoveToParentViewController:self];
        [self.barContainerView addSubview:actionBarVC.view];
        
        [_actionBarVC animateInWithDuration:.2f
                                 completion:^(BOOL finished)
         {
             if ([self.sequence isPoll])
                 [self pollAnimation];
         }];
    }
}

- (void)updateActionBar
{
    if (!self.isViewLoaded)
    {
        return;
    }
    
    VActionBarViewController* newActionBar;
    
    //Find the appropriate target based on what view is hidden
    
    if([self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VPollAnswerBarViewController class]])
    {
        VPollAnswerBarViewController* pollAnswerBar = [VPollAnswerBarViewController sharedInstance];
        pollAnswerBar.delegate = self;
        newActionBar = pollAnswerBar;
    }
    else if (![self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VEmotiveBallisticsBarViewController class]])
    {
        VEmotiveBallisticsBarViewController* emotiveBallistics = [VEmotiveBallisticsBarViewController sharedInstance];
        emotiveBallistics.target = self.previewImage;
        newActionBar = emotiveBallistics;
    }
    
    newActionBar.sequence = self.sequence;
    
    if (self.actionBarVC && newActionBar)
    {
        [self.actionBarVC animateOutWithDuration:.2f
                                      completion:^(BOOL finished)
                                      {
                                          self.actionBarVC = newActionBar;
                                      }];
    }
    else if (newActionBar)
    {
        self.actionBarVC = newActionBar;
    }
}

#pragma mark - Sequence Logic
- (void)loadNextAsset
{
    if (!self.currentAsset)
        self.currentAsset = [self.currentNode firstAsset];
    //    else
    //        self.currentAsset = [self.currentNode nextAssetFromAsset:self.currentAsset];
    
    if ([self.currentAsset isVideo])
        [self loadVideo];
    
    else //Default case: we assume its an image and hope it works out
        [self loadImage];
}

#pragma mark - Quiz
- (void)loadQuiz
{
    //self.actionBar = [VActionBarViewController quizBar];
}

#pragma mark - Button Actions
- (IBAction)pressedMore:(id)sender
{
    //Specced but still no idea what its supposed to do
}

- (IBAction)pressedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedComment:(id)sender
{
    [self.navigationController pushViewController:[VCommentsContainerViewController commentsContainerView] animated:YES];
}

#pragma mark - VInteractionManagerDelegate
- (void)firedInteraction:(VInteraction*)interaction
{
    VLog(@"Interaction fired:%@", interaction);
}

#pragma mark - Navigation
- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController*)fromVC
                                                  toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPop)
    {
        VContentToStreamAnimator* animator = [[VContentToStreamAnimator alloc] init];
//        animator.indexPathForSelectedCell = self.tableView.indexPathForSelectedRow;
        return animator;
    }
    else if (operation == UINavigationControllerOperationPush)
    {
        return [[VContentToCommentAnimator alloc] init];
    }
    return nil;
}


@end
