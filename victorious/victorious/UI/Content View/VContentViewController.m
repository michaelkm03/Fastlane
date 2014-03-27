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
#import "VContentTransitioningDelegate.h"

#import "UIImageView+Blurring.h"

#import "VEmotiveBallisticsBarViewController.h"

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
    
    self.transitionDelegate = [[VContentTransitioningDelegate alloc] init];
    
    self.firstResultView.isVertical = YES;
    self.firstResultView.hidden = YES;
    
    self.secondResultView.isVertical = YES;
    self.secondResultView.hidden = YES;
    
    for (UIButton* button in self.buttonCollection)
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentAccentColor];
    }
    self.descriptionLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentAccentColor];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVContentTitleFont];
    
    [self.remixButton setImage:[self.remixButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.remixButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.sequence = self.sequence;
    
    self.orImageView.hidden = ![self.currentNode isPoll];
    self.orImageView.alpha = 0;
    
    self.firstPollButton.alpha = 0;
    self.secondPollButton.alpha = 0;
    
    [self.topActionsView setYOrigin:self.mediaView.frame.origin.y];
    self.topActionsView.alpha = 0;
    [UIView animateWithDuration:.2f
                     animations:^
     {
         [self.topActionsView setYOrigin:0];
         self.topActionsView.alpha = 1;
         self.orImageView.alpha = 1;
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
    
    self.navigationController.navigationBarHidden = NO;
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

- (void)updateActionBar
{
    if (!self.isViewLoaded)
    {
        return;
    }
    
    UIViewController<VAnimation>* newBarViewController;
    
    //Find the appropriate target based on what view is hidden
    
    if([self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VPollAnswerBarViewController class]])
    {
        VPollAnswerBarViewController* pollAnswerBar = [VPollAnswerBarViewController sharedInstance];
        pollAnswerBar.sequence = self.sequence;
        pollAnswerBar.delegate = self;
        newBarViewController = pollAnswerBar;
    }
    else if (![self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VEmotiveBallisticsBarViewController class]])
    {
        VEmotiveBallisticsBarViewController* emotiveBallistics = [VEmotiveBallisticsBarViewController sharedInstance];
        emotiveBallistics.sequence = self.sequence;
        emotiveBallistics.target = self.previewImage;
        newBarViewController = emotiveBallistics;
    }
    else if ([self.actionBarVC isKindOfClass:[VEmotiveBallisticsBarViewController class]])
    {
        ((VEmotiveBallisticsBarViewController*)self.actionBarVC).target = self.previewImage;//Change the target if we need to
    }
    
    if (self.actionBarVC && newBarViewController)
    {
        [self.actionBarVC animateOutWithDuration:.2f
                                      completion:^(BOOL finished)
                                      {
                                          [self.actionBarVC removeFromParentViewController];
                                          [self.actionBarVC.view removeFromSuperview];
                                          [self addChildViewController:newBarViewController];
                                          [newBarViewController didMoveToParentViewController:self];
                                          [self.barContainerView addSubview:newBarViewController.view];
                                          self.actionBarVC = newBarViewController;
                                          
                                          [self.actionBarVC animateInWithDuration:.2f completion:^(BOOL finished) {
                                              [self pollAnimation];
                                          }];
                                      }];
    }
    else if (newBarViewController)
    {
        [self.actionBarVC removeFromParentViewController];
        [self.actionBarVC.view removeFromSuperview];
        [self addChildViewController:newBarViewController];
        [newBarViewController didMoveToParentViewController:self];
        [self.barContainerView addSubview:newBarViewController.view];
        self.actionBarVC = newBarViewController;
        
        [self.actionBarVC animateInWithDuration:.2f completion:^(BOOL finished) {
            [self pollAnimation];
        }];
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


#pragma mark - VInteractionManagerDelegate
- (void)firedInteraction:(VInteraction*)interaction
{
    VLog(@"Interaction fired:%@", interaction);
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((UIViewController*)segue.destinationViewController).transitioningDelegate = self.transitionDelegate;
    ((UIViewController*)segue.destinationViewController).modalPresentationStyle= UIModalPresentationCustom;
    [self.mpController stop];
    self.mpController = nil;
    
    if ([segue.identifier isEqualToString:kContentCommentSegueStoryboardID])
    {
        VCommentsContainerViewController* commentVC = segue.destinationViewController;
        commentVC.sequence = self.sequence;
    }
}

- (IBAction)unwindToContentView:(UIStoryboardSegue*)sender
{
    
}

@end
