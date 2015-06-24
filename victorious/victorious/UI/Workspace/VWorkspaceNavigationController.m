//
//  VWorkspaceNavigationController.m
//  victorious
//
//  Created by Sharif Ahmed on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceNavigationController.h"

@interface VWorkspaceNavigationController ()

@property (nonatomic, strong) UIViewController *rootViewController;

@end

@implementation VWorkspaceNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ( self.showAlertWhenAppearing )
    {
        self.rootViewController = [self.viewControllers firstObject];
        if ( [self.viewControllers firstObject] == nil )
        {
            UIViewController *viewController = [[UIViewController alloc] init];
            viewController.view.backgroundColor = [UIColor blackColor];
            self.viewControllers = @[viewController];
            self.rootViewController = viewController;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( self.showAlertWhenAppearing )
    {
        UIAlertController *cannotRemixAlert = [UIAlertController alertControllerWithTitle:nil
                                                                                  message:NSLocalizedString(@"GenericFailMessage", nil)
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action)
                                      {
                                          [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                      }];
        [cannotRemixAlert addAction:closeAction];
        [self.rootViewController presentViewController:cannotRemixAlert animated:YES completion:nil];
    }
}

@end
