//
//  VLoadingViewController.m
//  victorious
//
//  Created by Will Long on 2/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoadingViewController.h"

#import "VThemeManager.h"
#import "VConstants.h"

#import "VObjectManager+Sequence.h"

#import "VHomeStreamViewController.h"

@interface VLoadingViewController ()
@property (strong, nonatomic) UIActivityIndicatorView* indicator;
@end

@implementation VLoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (IS_IPHONE_5)
        self.view.layer.contents = (id)[[VThemeManager sharedThemeManager] themedImageForKeyPath:kVMenuBackgroundImage5].CGImage;
    else
        self.view.layer.contents = (id)[[VThemeManager sharedThemeManager] themedImageForKeyPath:kVMenuBackgroundImage].CGImage;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialLoadFinished:) name:kInitialLoadFinishedNotification object:nil];

	// Do any additional setup after loading the view.
}

- (void)initialLoadFinished:(NSNotification*)notif
{
    [UIView animateWithDuration:1.0f
                     animations:^
                     {
                         [self.navigationController pushViewController:[VHomeStreamViewController sharedInstance] animated:YES];
                     }
                     completion:^(BOOL finished)
                     {
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                     }];
    
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    self.navigationController.viewControllers = @[[VHomeStreamViewController sharedInstance]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
