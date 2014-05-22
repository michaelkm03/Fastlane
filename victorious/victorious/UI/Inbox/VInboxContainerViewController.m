//
//  VInboxContainerViewController.m
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInboxContainerViewController.h"
#import "VInboxViewController.h"

#import "VConstants.h"

@interface VInboxContainerViewController ()

@end

@implementation VInboxContainerViewController

+ (instancetype)inboxContainer
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VInboxContainerViewController* container = (VInboxContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kInboxContainerID];
    container.tableViewController = [VInboxViewController inboxViewController];
    ((VInboxViewController*)container.tableViewController).delegate = container;
    
    return container;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerLabel.text = NSLocalizedString(@"Inbox", nil);
}

@end
