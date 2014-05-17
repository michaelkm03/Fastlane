//
//  VContentViewController+Videos.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController+Images.h"
#import "VContentViewController+Private.h"
#import "VContentViewController+Videos.h"
#import "VObjectManager+Users.h"
#import "VLoginViewController.h"
#import "VRemixSelectViewController.h"

#import <objc/runtime.h>

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
    
    self.shouldPause = NO;
    [self.videoPlayer removeFromSuperview];
    self.videoPlayer = [[VCVideoPlayerView alloc] init];
    self.videoPlayer.delegate = self;
    self.videoPlayer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaView addSubview:self.videoPlayer];
    if ([self.currentNode isPoll])
    {
        [self addCloseButtonToVideoPlayer];
    }
    else
    {
        [self addRemixButtonToVideoPlayer];
    }
    
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:previewView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    self.videoPlayer.alpha = 0;
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
    remixButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    [remixButton setImage:[[UIImage imageNamed:@"cameraButtonRemix"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    [remixButton addTarget:self action:@selector(pressedRemix:) forControlEvents:UIControlEventTouchUpInside];
    remixButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    [self.videoPlayer.overlayView addSubview:remixButton];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[remixButton(==50)]-5-|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(remixButton)]];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[remixButton(==50)]"
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

- (void)unloadVideoWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    if (!self.videoPlayer && !self.temporaryVideoPreviewConstraints.count)
    {
        return;
    }
    
    [self pauseVideo];
    
    void (^animationCompletion)(BOOL) = ^(BOOL complete)
    {
        [self.videoPlayer removeFromSuperview];
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
        [UIView animateWithDuration:duration
                        delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void)
        {
            [self.mediaView removeConstraints:self.temporaryVideoPreviewConstraints];
            self.temporaryVideoPreviewConstraints = nil;
            [self.view layoutIfNeeded];
            self.previewImage.alpha = 1.0f;
            self.videoPlayer.alpha = 0;
        }
                         completion:animationCompletion];
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
    [UIView animateWithDuration:0.2f
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
                                                                           relatedBy:NSLayoutRelationLessThanOrEqual
                                                                              toItem:self.mediaView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0f
                                                                            constant:0.0f];
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
        self.videoPlayer.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
    {
        if (!self.shouldPause)
        {
            [self.videoPlayer.player play];
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

    UIViewController* remixVC = [VRemixSelectViewController remixViewControllerWithURL:[self.currentAsset.data mp4UrlFromM3U8] sequenceID:[self.sequence.remoteId integerValue] nodeID:[self.currentNode.remoteId integerValue]];
    [self presentViewController:remixVC animated:YES completion:
     ^{
         [self.videoPlayer.player pause];
     }];
}

- (IBAction)pressedClose:(id)sender
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [self forceRotationBackToPortraitOnCompletion:^(void)
        {
            [self pressedClose:sender];
        }];
        return;
    }
    
    [self unloadVideoWithDuration:0.2 completion:nil];
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

- (void)videoPlayerReadyToPlay:(VCVideoPlayerView *)videoPlayer
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    
    CGFloat ratio = fminf(self.videoPlayer.naturalSize.height / self.videoPlayer.naturalSize.width, 1);
    [self animateVideoOpenToAspectRatio:ratio];
}

- (void)videoPlayerFailed:(VCVideoPlayerView *)videoPlayer
{
    [self unloadVideoWithDuration:0.2f completion:^(void)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"VideoPlayFailed", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerView *)videoPlayer
{
    if (self.onVideoCompletionBlock)
    {
        self.onVideoCompletionBlock();
        self.onVideoCompletionBlock = nil;
    }
}

@end
