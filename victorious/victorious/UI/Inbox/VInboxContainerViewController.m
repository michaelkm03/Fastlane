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

typedef enum {
    vFilterBy_Messages = 0,
    vFilterBy_Notifications = 1

} vFilterBy;

@interface VInboxContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView* noMessagesView;
@property (weak, nonatomic) IBOutlet UILabel* noMessagesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* noMessagesMessageLabel;

@end

@implementation VInboxContainerViewController

+ (instancetype)inboxContainer
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VInboxContainerViewController* container = (VInboxContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kInboxContainerID];
//    container.tableViewController = [VInboxViewController inboxViewController];
    ((VInboxViewController*)container.tableViewController).delegate = container;
    
    return container;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.headerLabel.text = NSLocalizedString(@"Inbox", nil);
    [self.filterControls setSelectedSegmentIndex:vFilterBy_Messages];
}

- (IBAction)changedFilterControls:(id)sender
{
    
    [[VInboxViewController inboxViewController] toggleFilterControl:self.filterControls.selectedSegmentIndex];
    
}

@end
