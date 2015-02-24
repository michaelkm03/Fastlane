//
//  VFirstTimeUserVideoViewController.m
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFirstTimeUserVideoViewController.h"
#import "VButton.h"
#import "VDependencyManager.h"

@interface VFirstTimeUserVideoViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet VButton *getStartedButton;

@end

@implementation VFirstTimeUserVideoViewController

#pragma mark - Initializers

+ (VFirstTimeUserVideoViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]];
    return [storyboard instantiateViewControllerWithIdentifier:@"WelcomeVideo"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VFirstTimeUserVideoViewController *firstTimeVC = [self instantiateFromStoryboard:@"FirstTimeUserVideo"];
    firstTimeVC.dependencyManager = dependencyManager;
    return firstTimeVC;
}

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.getStartedButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.getStartedButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    [self.getStartedButton setTitle:NSLocalizedString(@"Get Started", @"") forState:UIControlStateNormal];
    self.getStartedButton.style = VButtonStylePrimary;

}

#pragma mark - Close Button Action

- (IBAction)getStartedButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
