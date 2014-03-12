//
//  VContentViewController.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"

#import "VConstants.h"

#import "VEmotiveBallisticsBarViewController.h"
#import "VPollAnswerBarViewController.h"

#import "VCommentsContainerViewController.h"
#import "VContentTransitioningDelegate.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VAnswer.h"
#import "VInteractionManager.h"

#import "UIImageView+Blurring.h"
#import "UIWebView+VYoutubeLoading.h"
#import "UIView+VFrameManipulation.h"
#import "NSString+VParseHelp.h"

CGFloat kContentMediaViewOffset = 154;

@import MediaPlayer;

@interface VContentViewController ()  <UIWebViewDelegate, VInteractionManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIButton* backButton;
@property (weak, nonatomic) IBOutlet UIButton* commentButton;
@property (weak, nonatomic) IBOutlet UIButton* moreButton;
@property (weak, nonatomic) IBOutlet UIImageView* previewImage;
@property (weak, nonatomic) IBOutlet UIImageView* sixteenNinePreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView* firstSmallPreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView* secondSmallPreviewImage;
@property (weak, nonatomic) IBOutlet UIWebView* webView;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView* barContainerView;

@property (strong, nonatomic) MPMoviePlayerController* mpController;
@property (strong, nonatomic) VNode* currentNode;
@property (strong, nonatomic) VAsset* currentAsset;
@property (strong, nonatomic) VInteractionManager* interactionManager;

@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;

@end

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
    
    self.transitionDelegate = [[VContentTransitioningDelegate alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mpLoadStateChanged)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    self.webView.scrollView.scrollEnabled = NO;
    [self.webView setAllowsInlineMediaPlayback:YES];
    [self.webView setMediaPlaybackRequiresUserAction:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.sequence = self.sequence;
    
    [self.topActionsView setYOrigin:self.mediaView.frame.origin.y];
    self.topActionsView.alpha = 0;
    [UIView animateWithDuration:.2f
                     animations:^
     {
         [self.topActionsView setYOrigin:0];
         self.topActionsView.alpha = 1;
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
    [self.backgroundImage setLightBlurredImageWithURL:[NSURL URLWithString:self.sequence.previewImage]
                                     placeholderImage:nil];
    self.descriptionLabel.text = _sequence.sequenceDescription;
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
    UIView* target = !self.webView.hidden ? self.webView : !self.mpController.view.hidden ? self.mpController.view : self.previewImage;
    
    if([self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VPollAnswerBarViewController class]])
    {
        newBarViewController = [VPollAnswerBarViewController sharedInstance];
        ((VPollAnswerBarViewController*)newBarViewController).sequence = self.sequence;
    }
    else if (![self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VEmotiveBallisticsBarViewController class]])
    {
        VEmotiveBallisticsBarViewController* emotiveBallistics = [VEmotiveBallisticsBarViewController sharedInstance];
        emotiveBallistics.target = target;
        newBarViewController = emotiveBallistics;
    }
    else if ([self.actionBarVC isKindOfClass:[VEmotiveBallisticsBarViewController class]])
    {
        ((VEmotiveBallisticsBarViewController*)self.actionBarVC).target = target;//Change the target if we need to
    }
    
    if (self.actionBarVC && newBarViewController)
    {
        [self.actionBarVC animateOutWithDuration:.4f
                                      completion:^(BOOL finished)
                                      {
                                          [self.actionBarVC removeFromParentViewController];
                                          [self.actionBarVC.view removeFromSuperview];
                                          [self addChildViewController:newBarViewController];
                                          [newBarViewController didMoveToParentViewController:self];
                                          [self.barContainerView addSubview:newBarViewController.view];
                                          self.actionBarVC = newBarViewController;
                                          
                                          [self.actionBarVC animateInWithDuration:.4f completion:nil];
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
        
        [self.actionBarVC animateInWithDuration:.4f completion:nil];
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
    else if ([self.currentAsset isYoutube])
        [self loadYoutubeVideo];
    
    else //Default case: we assume its an image and hope it works out
        [self loadImage];
}

#pragma mark - Poll
- (void)loadPoll
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    NSString* firstAssetUrl = ((VAnswer*)[answers firstObject]).mediaUrl;
    NSString* secondAssetUrl = ((VAnswer*)[answers lastObject]).mediaUrl;
    if ([[firstAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        [self.firstSmallPreviewImage setImageWithURL:[NSURL URLWithString:[firstAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        [self.firstSmallPreviewImage setImageWithURL:[NSURL URLWithString:firstAssetUrl]];
    }
    
    if ([[secondAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        [self.secondSmallPreviewImage setImageWithURL:[NSURL URLWithString:[secondAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        [self.secondSmallPreviewImage setImageWithURL:[NSURL URLWithString:secondAssetUrl]];
    }
    
    self.firstSmallPreviewImage.hidden = NO;
    self.secondSmallPreviewImage.hidden = NO;
    self.previewImage.hidden = YES;
    self.webView.hidden = YES;
    self.sixteenNinePreviewImage.hidden = YES;
    self.mpController.view.hidden = YES;
    
    [self updateActionBar];
}

#pragma mark - Quiz
- (void)loadQuiz
{
    //self.actionBar = [VActionBarViewController quizBar];
}

#pragma mark - Image
- (void)loadImage
{
    NSURL* imageUrl;
    if ([self.currentAsset.type isEqualToString:VConstantsMediaTypeImage])
    {
        imageUrl = [NSURL URLWithString:self.currentAsset.data];
    }
    else
    {
        imageUrl = [NSURL URLWithString:self.sequence.previewImage];
    }
    
    [self.previewImage setImageWithURL:imageUrl];
    
    self.previewImage.hidden = NO;
    self.webView.hidden = YES;
    self.sixteenNinePreviewImage.hidden = YES;
    self.firstSmallPreviewImage.hidden = YES;
    self.secondSmallPreviewImage.hidden = YES;
    self.mpController.view.hidden = YES;
    
    [self updateActionBar];
}


#pragma mark - Video
- (void)loadVideo
{
    [self loadImage];
    
    [self.mpController.view removeFromSuperview];
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.currentAsset.data]];
    self.mpController.view.hidden = YES;
    [self.mpController prepareToPlay];
    self.mpController.scalingMode = MPMovieScalingModeAspectFill;
    self.mpController.view.frame = self.previewImage.frame;
    VLog(@"pi frame: %@", NSStringFromCGRect(self.previewImage.frame));
    VLog(@"mp nat size: %@", NSStringFromCGSize(self.mpController.naturalSize));
    [self.mediaView insertSubview:self.mpController.view aboveSubview:self.previewImage];
    
    [self updateActionBar];
}

- (void)mpLoadStateChanged
{
    if (self.mpController.loadState == MPMovieLoadStatePlayable)
    {
        VLog(@"mp nat size: %@", NSStringFromCGSize(self.mpController.naturalSize));
        CGFloat yRatio = self.mpController.naturalSize.height / self.mpController.naturalSize.width;
        CGFloat videoHeight = self.previewImage.frame.size.height * yRatio;
        self.mpController.view.frame = CGRectMake(self.previewImage.frame.origin.x, self.previewImage.frame.origin.y,
                                                  self.previewImage.frame.size.width, videoHeight);
        
        self.mpController.view.hidden = NO;
        [self.mpController play];
    }
}

#pragma mark - Youtube
- (void)loadYoutubeVideo
{
    NSURL* imageUrl;
    if ([self.currentAsset.type isEqualToString:VConstantsMediaTypeImage])
    {
        imageUrl = [NSURL URLWithString:self.currentAsset.data];
    }
    else
    {
        imageUrl = [NSURL URLWithString:self.sequence.previewImage];
    }
    
    [self.sixteenNinePreviewImage setImageWithURL:imageUrl];
    
    self.sixteenNinePreviewImage.hidden = NO;
    self.previewImage.hidden = YES;
    self.webView.hidden = YES;
    self.firstSmallPreviewImage.hidden = YES;
    self.secondSmallPreviewImage.hidden = YES;
    self.mpController.view.hidden = YES;
    [self.webView loadWithYoutubeID:self.currentAsset.data];
    
    [self updateActionBar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
}

#pragma mark - Button Actions
- (IBAction)pressedBack:(id)sender
{
    [self.actionBarVC animateOutWithDuration:.4f
                                  completion:^(BOOL finished)
                                  {
                                      [self backAnimation];
                                  }];
}

- (void)backAnimation
{
    [UIView animateWithDuration:.2f
                     animations:^
     {
         [self.topActionsView setYOrigin:self.mediaView.frame.origin.y];
         self.topActionsView.alpha = 0;
     } completion:^(BOOL finished) {
         [self.navigationController popViewControllerAnimated:NO];//dismissViewControllerAnimated:YES completion:nil];
     }];
}

- (IBAction)pressedMore:(id)sender
{
    //Specced but still no idea what its supposed to do
}

- (IBAction)pressedPlay:(id)sender
{
    if ([self.currentAsset isYoutube])
    {
        self.webView.hidden = NO;
        [self.webView setMediaPlaybackRequiresUserAction:NO];
    }
    
    else
        [self.mpController play];
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
    [self.mpController.view removeFromSuperview];
    self.mpController = nil;
    [self.webView loadHTMLString:nil baseURL:nil];
    
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
