//
//  VContentViewController.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+ForceOrientationChange.h"

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
    
    self.mediaSuperview.translatesAutoresizingMaskIntoConstraints = YES; // these two views need to opt-out of Auto Layout.
    self.mediaView.translatesAutoresizingMaskIntoConstraints = YES;      // their frames are set in -layoutMediaSuperview.

    UIView *maskingView = self.maskingView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[maskingView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(maskingView)]];
    
    for (UIButton* button in self.buttonCollection)
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    }
    self.descriptionLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    [self resetView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.appearing)
    {
        self.appearing = YES;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self updateActionBar];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutMediaSuperview];
}

- (void)layoutMediaSuperview
{
    if (CGAffineTransformIsIdentity(self.mediaSuperview.transform))
    {
        self.mediaSuperview.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                               CGRectGetMaxY(self.topActionsView.frame),
                                               CGRectGetWidth(self.view.bounds),
                                               320.0f);
    }
    else
    {
        self.mediaSuperview.bounds = CGRectMake(0,
                                                0,
                                                CGRectGetHeight(self.view.bounds),
                                                CGRectGetWidth(self.view.bounds));
        self.mediaSuperview.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                                 CGRectGetMidY(self.view.bounds));
    }
    self.mediaView.frame = self.mediaSuperview.bounds;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if  ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        self.appearing = NO;
        [self resetView];
    }
}

- (void)resetView
{
    [self.firstResultView setProgress:0 animated:NO];
    self.firstResultView.isVertical = YES;
    self.firstResultView.hidden = YES;
    self.firstResultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    [self.secondResultView setProgress:0 animated:NO];
    self.secondResultView.isVertical = YES;
    self.secondResultView.hidden = YES;
    self.secondResultView.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.firstPollPlayIcon.hidden = YES;
    self.secondPollPlayIcon.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        self.orAnimator = nil;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (!self.isRotating && [self isVideoLoaded])
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)forceRotationBackToPortraitOnCompletion:(void (^)(void))completion
{
    [self forceRotationBackToPortraitWithExtraAnimations:nil onCompletion:completion];
}

- (void)forceRotationBackToPortraitWithExtraAnimations:(void(^)(void))animations onCompletion:(void(^)(void))completion
{
    self.isRotating = YES;
    [self beforeRotationToInterfaceOrientation:UIInterfaceOrientationPortrait];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void)
    {
        if (animations)
        {
            animations();
        }
        [self duringRotationToInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
                     completion:^(BOOL finished)
    {
        [self afterRotationToNewInterfaceOrientation:UIInterfaceOrientationPortrait];
        [UIViewController v_forceOrientationChange];
        self.isRotating = NO;
        if (completion)
        {
            completion();
        }
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self beforeRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!self.isRotating) // if this is a "forced" rotation, the animations would have been completed by now.
    {
        [self duringRotationToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self afterRotationToNewInterfaceOrientation:self.interfaceOrientation];
}

- (void)beforeRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.maskingView.alpha = 0;
        self.maskingView.hidden = NO;
    }
}

- (void)duringRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        CGAffineTransform rotationTransform = rootView.transform;
        rootView.transform = CGAffineTransformIdentity;
        rootView.bounds = CGRectMake(0, 0, CGRectGetHeight(rootView.bounds), CGRectGetWidth(rootView.bounds));
        self.mediaSuperview.transform = rotationTransform;
        self.maskingView.alpha = 1.0f;
    }
    else
    {
        self.mediaSuperview.transform = CGAffineTransformIdentity;
        self.maskingView.alpha = 0;
    }
    [self layoutMediaSuperview];
    [self.mediaView layoutIfNeeded];
}

- (void)afterRotationToNewInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.maskingView.hidden = YES;
    }
}

#pragma mark -

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
    {
        self.currentAsset = [self.currentNode firstAsset];
    }
    
    if ([self.currentAsset isVideo])
    {
        [self loadImage]; // load the video thumbnail
        [self playVideoAtURL:[NSURL URLWithString:self.currentAsset.data] withPreviewView:self.previewImage];
    }
    else //Default case: we assume it's an image and hope it works out
    {
        [self loadImage];
    }
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
    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = self.sequence;
    commentsTable.parentVC = self;
    [self.navigationController pushViewController:commentsTable animated:YES];
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
        return [[VContentToStreamAnimator alloc] init];
    }
    else if (operation == UINavigationControllerOperationPush)
    {
        return [[VContentToCommentAnimator alloc] init];
    }
    return nil;
}

#pragma mark - Animations
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:.25f
                     animations:^
     {
         for (UIView* view in self.view.subviews)
         {
             if ([view isKindOfClass:[UIImageView class]])
                 continue;
             
             if (view.center.y > self.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y - self.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y + self.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         if (completion)
         {
             completion(finished);
         }
     }];
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                     animations:^
     {
         for (UIView* view in self.view.subviews)
         {
             if ([view isKindOfClass:[UIImageView class]])
                 continue;
             
             if (view.center.y > self.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y + self.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y - self.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         if(completion)
         {
             completion(finished);
         }
     }];
}

@end
