//
//  VPopupVideoViewController.m
//  victorious
//
//  Created by Josh Hinman on 5/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLightboxViewController.h"

@interface VLightboxViewController ()

@property (nonatomic) BOOL hasAppeared; ///< YES after viewDidAppear is called

@end


@implementation VLightboxViewController

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.autoresizesSubviews = NO;

    if (self.backgroundView)
    {
        [self.view addSubview:self.backgroundView];
    }
    
    self.contentSuperview = [[UIView alloc] init];
    self.contentSuperview.backgroundColor = [UIColor clearColor];
    self.contentSuperview.opaque = NO;
    [self.view addSubview:self.contentSuperview];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedClose:)];
    [self.contentSuperview addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.backgroundView.frame = self.view.bounds;
    [self layoutContentSuperview];
}

- (void)layoutContentSuperview
{
    self.contentSuperview.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                               CGRectGetMidY(self.view.bounds));

    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        self.contentSuperview.bounds = CGRectMake(0,
                                                  0,
                                                  CGRectGetWidth(self.view.bounds),
                                                  CGRectGetHeight(self.view.bounds));
    }
    else
    {
        self.contentSuperview.bounds = CGRectMake(0,
                                                  0,
                                                  CGRectGetHeight(self.view.bounds),
                                                  CGRectGetWidth(self.view.bounds));
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hasAppeared = YES;
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        self.hasAppeared = NO;
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return self.hasAppeared;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self beforeRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self duringRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self afterRotationToNewInterfaceOrientation:self.interfaceOrientation];
}

- (void)beforeRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
}

- (void)duringRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (toInterfaceOrientation != UIInterfaceOrientationPortrait)
    {
        self.view.transform = CGAffineTransformIdentity;
        self.view.bounds = CGRectMake(0, 0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds));
        self.contentSuperview.transform = [self transformForInterfaceOrientation:toInterfaceOrientation];
    }
    else
    {
        self.contentSuperview.transform = CGAffineTransformIdentity;
    }
}

- (void)afterRotationToNewInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
}

- (CGAffineTransform)transformForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI / 2.0);
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(M_PI * 1.5);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
            break;

        default:
        case UIInterfaceOrientationPortrait:
            return CGAffineTransformIdentity;
            break;
    }
}

#pragma mark - Properties

- (UIView *)contentView
{
    NSAssert(NO, @"Subclasses of VLightboxViewController need to implement -contentView");
    return nil;
}

- (void)setBackgroundView:(UIImageView *)backgroundView
{
    if ([self isViewLoaded])
    {
        [_backgroundView removeFromSuperview];
        backgroundView.frame = self.view.bounds;
        [self.view insertSubview:backgroundView atIndex:0];
    }
    _backgroundView = backgroundView;
}

#pragma mark - Actions

- (IBAction)pressedClose:(id)sender
{
    if (self.onCloseButtonTapped)
    {
        self.onCloseButtonTapped();
    }
}

@end
