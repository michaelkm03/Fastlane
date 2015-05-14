//
//  VPermissionAlertViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionAlertViewController.h"
#import "VDependencyManager.h"

static NSString * const kStoryboardName = @"PermissionAlert";

@interface VPermissionAlertViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (weak, nonatomic) IBOutlet UIView *alertContainerView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmationButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation VPermissionAlertViewController

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    VPermissionAlertViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.alertContainerView.layer.cornerRadius = 10.0f;
    self.alertContainerView.clipsToBounds = YES;
    
    self.messageLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    self.confirmationButton.font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.view addSubview:self.view];
}

@end
