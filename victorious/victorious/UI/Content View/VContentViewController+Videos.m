//
//  VContentViewController+Videos.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VContentViewController+Images.h"
#import "VContentViewController+Private.h"
#import "VContentViewController+Videos.h"
#import "VObjectManager+Users.h"
#import "VLoginViewController.h"
#import "VRemixSelectViewController.h"

#import <objc/runtime.h>

const NSTimeInterval kVideoPlayerAnimationDuration = 0.2;

static const char kShouldPauseKey;
static const char kVideoPreviewViewKey;
static const char kVideoCompletionBlockKey;
static const char kVideoUnloadBlockKey;

@interface VContentViewController (VideosPrivate)

@property (nonatomic) BOOL shouldPause;

@end

@implementation VContentViewController (VideosPrivate)

- (void)setShouldPause:(BOOL)shouldPause
{
    objc_setAssociatedObject(self, &kShouldPauseKey, @(shouldPause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldPause
{
    NSNumber *shouldPause = objc_getAssociatedObject(self, &kShouldPauseKey);
    return [shouldPause boolValue];
}

@end

@implementation VContentViewController (Videos)

- (void)playVideoAtURL:(NSURL *)contentURL withPreviewView:(UIView *)previewView
{
    NSAssert(![self isVideoLoadingOrLoaded], @"attempt to play two videos at once--not allowed.");
    NSAssert([self.mediaView.subviews containsObject:previewView], @"previewView must be a subview of mediaView");
    
    if (self.videoPlayer)
    {
        [self.videoPlayer willMoveToParentViewController:nil];
        [self.videoPlayer.view removeFromSuperview];
        [self.videoPlayer removeFromParentViewController];
        self.videoPlayer = nil;
    }
    
    self.shouldPause = NO;
    self.videoPlayer = [[VCVideoPlayerViewController alloc] init];
    self.videoPlayer.delegate = self;
    self.videoPlayer.titleForAnalytics = self.sequence.name;
    
    [self addChildViewController:self.videoPlayer];
    self.videoPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaView addSubview:self.videoPlayer.view];
    
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    self.videoPlayer.view.alpha = 0;
    [self didMoveToParentViewController:self];

    if ([self.currentNode isPoll])
    {
        [self addCloseButtonToVideoPlayer];
    }
    else
    {
        [self addRemixButtonToVideoPlayer];
    }
    
    [self.videoPlayer setItemURL:contentURL];
    
    self.activityIndicator = [[VActivityIndicatorView alloc] init];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaView addSubview:self.activityIndicator];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0]];
    [self.activityIndicator startAnimating];
    self.videoPreviewView = previewView;
}

- (void)pauseVideo
{
    if ([self.videoPlayer isPlaying])
    {
        [self.videoPlayer.player pause];
    }
    else
    {
        self.shouldPause = YES;
    }
}

- (void)addRemixButtonToVideoPlayer
{
    UIButton *remixButton = [UIButton buttonWithType:UIButtonTypeCustom];
    remixButton.translatesAutoresizingMaskIntoConstraints = NO;
    remixButton.backgroundColor = [UIColor clearColor];
    [remixButton setImage:[[UIImage imageNamed:@"cameraButtonRemix"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                 forState:UIControlStateNormal];
    [remixButton addTarget:self action:@selector(pressedRemix:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoPlayer.overlayView addSubview:remixButton];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[remixButton(==49)]-6-|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(remixButton)]];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[remixButton(==50)]"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(remixButton)]];
}

- (void)addCloseButtonToVideoPlayer
{
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    [closeButton setImage:[[UIImage imageNamed:@"Close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    [self.videoPlayer.overlayView addSubview:closeButton];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[closeButton(==50)]-5-|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(closeButton)]];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[closeButton(==50)]"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(closeButton)]];
}

- (BOOL)isVideoLoadingOrLoaded
{
    return self.videoPlayer || self.temporaryVideoPreviewConstraints.count;
}

- (BOOL)isVideoLoaded
{
    return self.temporaryVideoPreviewConstraints.count;
}

- (void)unloadVideoWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    if (!self.videoPlayer && !self.temporaryVideoPreviewConstraints.count)
    {
        return;
    }
    
    [self pauseVideo];
    
    void (^animationCompletion)(BOOL) = ^(BOOL complete)
    {
        [self.view insertSubview:self.mediaSuperview belowSubview:self.pollPreviewView];
        
        [self.videoPlayer willMoveToParentViewController:nil];
        [self.videoPlayer.view removeFromSuperview];
        [self.videoPlayer removeFromParentViewController];
        self.videoPlayer = nil;
        
        if (self.onVideoUnloadBlock)
        {
            self.onVideoUnloadBlock();
            self.onVideoUnloadBlock = nil;
        }
        if (completion)
        {
            completion();
        }
    };

    if (self.temporaryVideoPreviewConstraints.count)
    {
        void (^animations)(void) = ^(void)
        {
            [self.mediaView removeConstraints:self.temporaryVideoPreviewConstraints];
            self.temporaryVideoPreviewConstraints = nil;
            self.previewImage.alpha = 1.0f;
            self.videoPlayer.view.alpha = 0;
        };
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            [self forceRotationBackToPortraitWithExtraAnimations:animations
                                                    onCompletion:^(void)
            {
                animationCompletion(YES);
            }];
        }
        else
        {
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(void)
            {
                animations();
                [self.mediaView layoutIfNeeded];
            }
                             completion:animationCompletion];
        }
    }
    else
    {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
        animationCompletion(YES);
    }
}

- (void)animateVideoOpenToAspectRatio:(CGFloat)aspectRatio
{
    [UIView animateWithDuration:kVideoPlayerAnimationDuration
                     animations:^(void)
    {
        NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:self.videoPreviewView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.mediaView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0f
                                                                        constant:0.0f];
        NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:self.videoPreviewView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.mediaView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0f
                                                                        constant:0.0];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.videoPreviewView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.mediaView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0f
                                                                            constant:0.0f];
        widthConstraint.priority = UILayoutPriorityRequired - 1;
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.videoPreviewView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.videoPreviewView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:aspectRatio
                                                                             constant:0];
        NSLayoutConstraint *maxHeightConstraint = [NSLayoutConstraint constraintWithItem:self.videoPreviewView
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                  toItem:self.mediaView
                                                                               attribute:NSLayoutAttributeHeight
                                                                              multiplier:1.0f
                                                                                constant:0.0f];
        NSArray *temporaryConstraints = @[yConstraint, xConstraint, widthConstraint, heightConstraint, maxHeightConstraint];
        [self.mediaView addConstraints:temporaryConstraints];
        self.temporaryVideoPreviewConstraints = temporaryConstraints;
        [self.view layoutIfNeeded];
        self.previewImage.alpha = 0;
        self.videoPlayer.view.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
    {
        if (!self.shouldPause)
        {
            if (![self isTitleExpanded])
            {
                [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryVideo action:@"Start Video" label:self.sequence.name value:nil];
                [self.videoPlayer.player play];
            }
        }
    }];
}

- (IBAction)pressedRemix:(id)sender
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [self forceRotationBackToPortraitOnCompletion:^(void)
        {
            [self pressedRemix:sender];
        }];
        return;
    }
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Pressed Remix" label:self.sequence.name value:nil];
    UIViewController* remixVC = [VRemixSelectViewController remixViewControllerWithURL:[self.currentAsset.data mp4UrlFromM3U8] sequenceID:[self.sequence.remoteId integerValue] nodeID:[self.currentNode.remoteId integerValue]];
    [self presentViewController:remixVC animated:YES completion:
     ^{
         [self.videoPlayer.player pause];
     }];
}

- (IBAction)pressedClose:(id)sender
{
    [self unloadVideoWithDuration:kVideoPlayerAnimationDuration completion:nil];
}

#pragma mark - Properties

- (void)setVideoPreviewView:(UIView *)videoPreviewView
{
    objc_setAssociatedObject(self, &kVideoPreviewViewKey, videoPreviewView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)videoPreviewView
{
    return objc_getAssociatedObject(self, &kVideoPreviewViewKey);
}

- (void)setOnVideoCompletionBlock:(void (^)(void))completion
{
    objc_setAssociatedObject(self, &kVideoCompletionBlockKey, [completion copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)(void))onVideoCompletionBlock
{
    return objc_getAssociatedObject(self, &kVideoCompletionBlockKey);
}

- (void)setOnVideoUnloadBlock:(void (^)(void))onUnload
{
    objc_setAssociatedObject(self, &kVideoUnloadBlockKey, [onUnload copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)(void))onVideoUnloadBlock
{
    return objc_getAssociatedObject(self, &kVideoUnloadBlockKey);
}

#pragma mark - VCVideoPlayerDelegate methods

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    
    CGFloat ratio = fminf(self.videoPlayer.naturalSize.height / self.videoPlayer.naturalSize.width, 1);
    [self animateVideoOpenToAspectRatio:ratio];
}

- (void)videoPlayerFailed:(VCVideoPlayerViewController *)videoPlayer
{
    [self unloadVideoWithDuration:kVideoPlayerAnimationDuration completion:^(void)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"VideoPlayFailed", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    if (self.onVideoCompletionBlock)
    {
        self.onVideoCompletionBlock();
        self.onVideoCompletionBlock = nil;
    }
}

@end
