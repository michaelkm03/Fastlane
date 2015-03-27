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
@property (nonatomic, weak, readwrite) IBOutlet UIView *contentSuperview;
@property (nonatomic, weak, readwrite) IBOutlet UIView *backgroundView;

@end

@implementation VLightboxViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:NSStringFromClass([VLightboxViewController class]) bundle:nil];
    if (self)
    {
    }
    return self;
}

#pragma mark - View lifecycle

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
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        return NO;
    }
    return self.hasAppeared;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self isBeingDismissed] || [self isMovingFromParentViewController])
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Properties

- (UIView *)contentView
{
    NSAssert(NO, @"Subclasses of VLightboxViewController need to implement -contentView");
    return nil;
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
