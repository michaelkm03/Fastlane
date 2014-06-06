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
}

//- (IBAction)changedFilterControls:(id)sender
//{
//    if (self.filterControls.selectedSegmentIndex == VStreamFollowingFilter && ![VObjectManager sharedManager].mainUser)
//    {
//        [self.filterControls setSelectedSegmentIndex:self.streamTable.filterType];
//        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
//    }
//    
//    [super changedFilterControls:sender];
//    
//    self.streamTable.filterType = self.filterControls.selectedSegmentIndex;
//}

@end
