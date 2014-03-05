//
//  VContentViewController.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"

#import "VConstants.h"

#import "VCommentsContainerViewController.h"
#import "VEmotiveBallisticsBarViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

#import "UIImageView+Blurring.h"
#import "UIWebView+VYoutubeLoading.h"
#import "UIView+VFrameManipulation.h"

CGFloat kContentMediaViewOffset = 154;

@import MediaPlayer;

@interface VContentViewController ()  <UIWebViewDelegate>

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
@property (weak, nonatomic) IBOutlet UIView* barView;
@property (weak, nonatomic) IBOutlet UIView* topActionsView;

@property (strong, nonatomic) VEmotiveBallisticsBarViewController* emotiveBallisticsBar;

@property (strong, nonatomic) MPMoviePlayerController* mpController;
@property (strong, nonatomic) VNode* currentNode;
@property (strong, nonatomic) VAsset* currentAsset;

@end

@implementation VContentViewController

- (void) dealloc
{
    _emotiveBallisticsBar.target = nil;
}

+ (VContentViewController *)sharedInstance
{
    static  VContentViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VContentViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kContentViewStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mpLoadStateChanged)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    self.webView.scrollView.scrollEnabled = NO;
    [self.webView setAllowsInlineMediaPlayback:YES];
    [self.webView setMediaPlaybackRequiresUserAction:NO];
    
    [self.topActionsView setYOrigin:self.mediaView.frame.origin.y];
    self.topActionsView.alpha = 0;
    [UIView animateWithDuration:.2f
                     animations:^
     {
         [self.topActionsView setYOrigin:0];
         self.topActionsView.alpha = 1;
     } completion:^(BOOL finished) {
         VEmotiveBallisticsBarViewController* emotiveBallistics = [VEmotiveBallisticsBarViewController sharedInstance];
         emotiveBallistics.target = self.previewImage;
         self.emotiveBallisticsBar = emotiveBallistics;
         [self.emotiveBallisticsBar animateIn];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.sequence = self.sequence;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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
}

- (void)setEmotiveBallisticsBar:(VEmotiveBallisticsBarViewController *)emotiveBallisticsBar
{
    if (_emotiveBallisticsBar != emotiveBallisticsBar)
    {
        [_emotiveBallisticsBar.view removeFromSuperview];
        [_emotiveBallisticsBar removeFromParentViewController];
        
        [self addChildViewController:emotiveBallisticsBar];
        [emotiveBallisticsBar didMoveToParentViewController:self];
        [self.barView addSubview:emotiveBallisticsBar.view];
        [_emotiveBallisticsBar animateIn];
        _emotiveBallisticsBar = emotiveBallisticsBar;
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
    //self.actionBar = [VActionBarViewController pollBar];
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
    self.emotiveBallisticsBar.target = self.previewImage;
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
    VLog(@"mp frame: %@", NSStringFromCGRect(self.mpController.view.frame));
    [self.mediaView insertSubview:self.mpController.view aboveSubview:self.previewImage];
    self.emotiveBallisticsBar.target = self.mpController.view;
}

- (void)mpLoadStateChanged
{
    if (self.mpController.loadState == MPMovieLoadStatePlayable)
    {
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
    self.emotiveBallisticsBar.target = self.webView;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
}

#pragma mark - Button Actions
- (IBAction)pressedBack:(id)sender
{
    [self.emotiveBallisticsBar animateOut];
    
    [self performSelector:@selector(backAnimation) withObject:nil afterDelay:.4f];
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

- (IBAction)presssedComment:(id)sender
{
    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = self.sequence;
    [self.navigationController pushViewController:commentsTable animated:YES];
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

@end
