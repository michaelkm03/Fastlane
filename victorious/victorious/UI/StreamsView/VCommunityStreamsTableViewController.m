//
//  VCommunityStreamsTableViewController.m
//  victorious
//
//  Created by Will Long on 1/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommunityStreamsTableViewController.h"
#import "VStreamsTableViewController+Protected.h"
#import "UIActionSheet+BBlock.h"
#import "BBlock.h"
#import "VCreateViewController.h"
#import "VCreatePollViewController.h"

#import "VObjectManager.h"
#import "VLoginViewController.h"

#import "VConstants.h"

@implementation VCommunityStreamsTableViewController

+ (instancetype)sharedStreamsTableViewController
{
    static  VCommunityStreamsTableViewController*   streamsTableViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        streamsTableViewController = (VCommunityStreamsTableViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"communitystream"];
    });
    
    return streamsTableViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(displaySearchBar:)];

    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(addButtonAction:)];

    self.navigationItem.rightBarButtonItems= @[addButtonItem, searchButtonItem];
}

- (NSArray*)imageCategories
{
    return @[kVUGCImageCategory];
}

- (NSArray*)videoCategories
{
    return @[kVUGCVideoCategory];
}

- (NSArray*)pollCategories
{
    return @[kVUGCPollCategory];
}

- (NSArray *)forumCategories
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return  nil;
}

- (IBAction)addButtonAction:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    BBlockWeakSelf wself = self;
    NSString *videoTitle = NSLocalizedString(@"Post Video", @"Post video button");
    NSString *photoTitle = NSLocalizedString(@"Post Photo", @"Post photo button");
    NSString *pollTitle = NSLocalizedString(@"Post Poll", @"Post poll button");
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc]
     initWithTitle:nil delegate:nil
     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
     destructiveButtonTitle:nil otherButtonTitles:videoTitle, photoTitle, pollTitle, nil];
    [actionSheet setCompletionBlock:^(NSInteger buttonIndex, UIActionSheet *actionSheet)
     {
         if(actionSheet.cancelButtonIndex == buttonIndex)
         {
             return;
         }

         if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:videoTitle])
         {
//             VCreateViewController *createViewController =
//             [[VCreateViewController alloc] initWithType:VImagePickerViewControllerVideo andDelegate:self];
//             [wself presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:photoTitle])
         {
//             VCreateViewController *createViewController =
//             [[VCreateViewController alloc] initWithType:VImagePickerViewControllerPhoto andDelegate:self];
//             [wself presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:pollTitle])
         {
//             VCreatePollViewController *createViewController = [[VCreatePollViewController alloc] initWithDelegate:self];
//             [wself presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
         }
     }];
    [actionSheet showInView:self.view];
}

@end
