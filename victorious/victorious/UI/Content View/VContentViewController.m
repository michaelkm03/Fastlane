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

#import "VResultView.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VAnswer.h"
#import "VInteractionManager.h"
#import "VPollResult.h"

#import "UIImageView+Blurring.h"
#import "UIWebView+VYoutubeLoading.h"
#import "UIView+VFrameManipulation.h"
#import "NSString+VParseHelp.h"

#import "VThemeManager.h"

#import "VRemixTrimViewController.h"

CGFloat kContentMediaViewOffset = 154;

@import MediaPlayer;

@interface VContentViewController ()  <UIWebViewDelegate, VInteractionManagerDelegate, VPollAnswerBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView* barContainerView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* buttonCollection;
@property (weak, nonatomic) IBOutlet UIButton* remixButton;

@property (weak, nonatomic) IBOutlet UIView* mpPlayerContainmentView;

@property (weak, nonatomic) IBOutlet UIImageView* previewImage;
@property (weak, nonatomic) IBOutlet UIImageView* sixteenNinePreviewImage;
@property (weak, nonatomic) IBOutlet UIWebView* webView;

@property (weak, nonatomic) IBOutlet UIView* pollPreviewView;
@property (weak, nonatomic) IBOutlet UIImageView* firstSmallPreviewImage;
@property (weak, nonatomic) IBOutlet UIImageView* secondSmallPreviewImage;
@property (weak, nonatomic) IBOutlet VResultView* firstResultView;
@property (weak, nonatomic) IBOutlet VResultView* secondResultView;
@property (weak, nonatomic) IBOutlet UIButton* firstPollButton;
@property (weak, nonatomic) IBOutlet UIButton* secondPollButton;

@property (weak, nonatomic) IBOutlet UIView* orContainerView;
@property (strong, nonatomic) UIDynamicAnimator* orAnimator;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateVideoClosed)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    self.webView.scrollView.scrollEnabled = NO;
    [self.webView setAllowsInlineMediaPlayback:YES];
    [self.webView setMediaPlaybackRequiresUserAction:NO];
    
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    self.mpController.scalingMode = MPMovieScalingModeAspectFill;
    self.mpController.view.frame = self.previewImage.frame;
    self.mpController.shouldAutoplay = NO;
    [self.mpPlayerContainmentView addSubview:self.mpController.view];
    
    self.firstResultView.isVertical = YES;
    self.firstResultView.hidden = YES;
    
    self.secondResultView.isVertical = YES;
    self.secondResultView.hidden = YES;
    
    for (UIButton* button in self.buttonCollection)
    {
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVContentAccentColor];
    }
    self.descriptionLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVContentAccentColor];
    
    [self.remixButton setImage:[self.remixButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.remixButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVAccentColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.sequence = self.sequence;
    
    self.orImageView.hidden = ![self.currentNode isPoll];
    self.orImageView.alpha = 0;
    
    [self.topActionsView setYOrigin:self.mediaView.frame.origin.y];
    self.topActionsView.alpha = 0;
    [UIView animateWithDuration:.2f
                     animations:^
     {
         [self.topActionsView setYOrigin:0];
         self.topActionsView.alpha = 1;
         self.orImageView.alpha = 1;
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

    [self.backgroundImage setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                     placeholderImage:nil];
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
    UIView* target = !self.webView.hidden ? self.webView : !self.mpPlayerContainmentView.hidden ? self.mpPlayerContainmentView : self.previewImage;
    
    if([self.sequence isPoll] && ![self.actionBarVC isKindOfClass:[VPollAnswerBarViewController class]])
    {
        VPollAnswerBarViewController* pollAnswerBar = [VPollAnswerBarViewController sharedInstance];
        pollAnswerBar.target = self.pollPreviewView;
        pollAnswerBar.sequence = self.sequence;
        pollAnswerBar.delegate = self;
        newBarViewController = pollAnswerBar;
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

- (void)pollAnimation
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         
                         [self.firstSmallPreviewImage setXOrigin:self.firstSmallPreviewImage.frame.origin.x - 1];
                         [self.secondSmallPreviewImage setXOrigin:self.secondSmallPreviewImage.frame.origin.x + 1];
                         
                         self.orImageView.hidden = ![self.currentNode isPoll];
                         self.orImageView.center = CGPointMake(self.orImageView.center.x, self.pollPreviewView.center.y);
                         self.orAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.orContainerView];
                         
                         UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.orImageView]];
                         gravityBehavior.magnitude = 4;
                         [self.orAnimator addBehavior:gravityBehavior];
                         
                         UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.orImageView]];
                         elasticityBehavior.elasticity = 0.2f;
                         [self.orAnimator addBehavior:elasticityBehavior];
                         
                         UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.orImageView]];
                         collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
                         [self.orAnimator addBehavior:collisionBehavior];
                     }];
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
    [self.firstSmallPreviewImage setImageWithURL:[((VAnswer*)[answers firstObject]).mediaUrl convertToPreviewImageURL]];
    [self.secondSmallPreviewImage setImageWithURL:[((VAnswer*)[answers lastObject]).mediaUrl convertToPreviewImageURL]];
    
    if ([[((VAnswer*)[answers firstObject]).mediaUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.firstPollButton.hidden = NO;
    }
    else
    {
        self.firstPollButton.hidden = YES;
    }
    if ([[((VAnswer*)[answers lastObject]).mediaUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.secondPollButton.hidden = NO;
    }
    else
    {
        self.secondPollButton.hidden = YES;
    }
    
    self.pollPreviewView.hidden = NO;
    self.previewImage.hidden = YES;
    self.webView.hidden = YES;
    self.sixteenNinePreviewImage.hidden = YES;
    self.mpPlayerContainmentView.hidden = YES;
    self.remixButton.hidden = YES;
    
    [self updateActionBar];
}

- (IBAction)playPoll:(id)sender
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    if( ((UIButton*)sender).tag == self.firstPollButton.tag)
    {
        [self.mpController setContentURL:[NSURL URLWithString:((VAnswer*)[answers firstObject]).mediaUrl]];
    }
    else if ( ((UIButton*)sender).tag == self.secondPollButton.tag)
    {
        [self.mpController setContentURL:[NSURL URLWithString:((VAnswer*)[answers lastObject]).mediaUrl]];
    }
    [self.mpController prepareToPlay];
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
    self.pollPreviewView.hidden = YES;
    self.mpPlayerContainmentView.hidden = YES;
    self.remixButton.hidden = NO;
    
    [self updateActionBar];
}

#pragma mark - Video
- (void)loadVideo
{
    [self loadImage];
    
    [self.mpController setContentURL:[NSURL URLWithString:self.currentAsset.data]];
    self.mpPlayerContainmentView.hidden = YES;
    [self.mpController prepareToPlay];
    
    [self updateActionBar];
}

- (void)mpLoadStateChanged
{
    if (self.mpController.loadState == MPMovieLoadStatePlayable && self.mpController.playbackState != MPMoviePlaybackStatePlaying)
    {
        VLog(@"mp nat size: %@", NSStringFromCGSize(self.mpController.naturalSize));
        CGFloat yRatio = 1;
        CGFloat xRatio = 1;
        if (self.mpController.naturalSize.height < self.mpController.naturalSize.width)
        {
            yRatio = self.mpController.naturalSize.height / self.mpController.naturalSize.width;
        }
        else if (self.mpController.naturalSize.height > self.mpController.naturalSize.width)
        {
            xRatio = self.mpController.naturalSize.width / self.mpController.naturalSize.height;
        }
        CGFloat videoHeight = self.previewImage.frame.size.height * yRatio;
        CGFloat videoWidth = self.previewImage.frame.size.width * xRatio;
        self.mpController.view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
        
        [self.mpPlayerContainmentView addSubview:self.mpController.view];
        
        [self animateVideoOpen];
    }
}

- (void)animateVideoOpen
{
    [self.mpPlayerContainmentView setSize:CGSizeMake(0, 0)];
    self.mpPlayerContainmentView.hidden = NO;

    CGFloat duration = [self.sequence isPoll] ? .5f : 0;//We only animate in poll videos

    [UIView animateWithDuration:duration animations:
     ^{
         [self.mpPlayerContainmentView setSize:CGSizeMake(self.mpController.view.frame.size.width, self.mpController.view.frame.size.height)];
     }
                     completion:^(BOOL finished)
    {
                         [self.mpController play];
                     }];
}

- (void)animateVideoClosed
{
    CGFloat duration = [self.sequence isPoll] ? .5f : 0;//We only animate in poll videos

    [UIView animateWithDuration:duration animations:
     ^{
         [self.mpPlayerContainmentView setSize:CGSizeMake(0,0)];
     }];
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
    self.pollPreviewView.hidden = YES;
    self.mpPlayerContainmentView.hidden = YES;
    self.remixButton.hidden = YES;
    [self.webView loadWithYoutubeID:self.currentAsset.data];
    
    [self updateActionBar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
}

#pragma mark - Button Actions
- (IBAction)pressedMore:(id)sender
{
    //Specced but still no idea what its supposed to do
}

- (IBAction)pressedRemix:(id)sender
{
    AVURLAsset* videoAsset = [AVURLAsset assetWithURL:[self.currentAsset.data mp4UrlFromM3U8]];
    UIViewController* remixVC = [VRemixTrimViewController remixViewControllerWithAsset:videoAsset];
    [self presentViewController:remixVC animated:YES completion:
    ^{
        [self.mpController stop];
    }];
}

#pragma mark - VInteractionManagerDelegate
- (void)firedInteraction:(VInteraction*)interaction
{
    VLog(@"Interaction fired:%@", interaction);
}

#pragma mark - VPollAnswerBarDelegate
- (void)answeredPollWithAnswerId:(NSNumber *)answerId
{
    [self.firstResultView setProgress:0 animated:NO];
    [self.secondResultView setProgress:0 animated:NO];
    
    NSInteger totalVotes = 0;
    for(VPollResult* result in self.sequence.pollResults)
    {
        totalVotes+= result.count.integerValue;
    }
    totalVotes = totalVotes ? totalVotes : 1; //dividing by 0 is bad.
    
    for(VPollResult* result in self.sequence.pollResults)
    {
        VResultView* resultView = [self resultViewForAnswerId:result.answerId];
        resultView.hidden = NO;
        
        CGFloat progress = result.count.doubleValue / totalVotes;
        
        if (result.answerId == answerId)
        {
            resultView.color = [UIColor purpleColor];//[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
        }
        else
        {
            resultView.color = [UIColor whiteColor];
        }
        
        [resultView setProgress:progress animated:YES];
    }
    //    self.firstResultLabel.hidden = self.secondResultLabel.hidden = NO;
    //    if ([answerId isEqualToNumber:self.firstAnswer.remoteId])
    //    {
    //        self.optionOneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
    //    }
    //    else if ([answerId isEqualToNumber:self.secondAnswer.remoteId])
    //    {
    //        self.optionTwoButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
    //    }
}

- (VResultView*)resultViewForAnswerId:(NSNumber*)answerId
{
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    if ([answerId isEqualToNumber:((VAnswer*)[answers firstObject]).remoteId])
        return self.firstResultView;
    
    else if ([answerId isEqualToNumber:((VAnswer*)[answers lastObject]).remoteId])
        return self.secondResultView;
    
    else return nil;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((UIViewController*)segue.destinationViewController).transitioningDelegate = self.transitionDelegate;
    ((UIViewController*)segue.destinationViewController).modalPresentationStyle= UIModalPresentationCustom;
    [self.mpController stop];
    self.mpController = nil;
    self.webView.hidden = YES;
    
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
