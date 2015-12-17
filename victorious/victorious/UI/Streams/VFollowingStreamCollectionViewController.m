//
//  VFollowingStreamCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowingStreamCollectionViewController.h"
#import "VObjectManager+Login.h"
#import "VDependencyManager+VObjectManager.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VNoContentView.h"
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "victorious-Swift.h"

@interface VFollowingStreamCollectionViewController ()

@end

@implementation VFollowingStreamCollectionViewController

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    NSString *identifier = NSStringFromClass([VFollowingStreamCollectionViewController class]);
    VFollowingStreamCollectionViewController *streamCollection = (VFollowingStreamCollectionViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:identifier];
    streamCollection.currentStream = stream;
    return streamCollection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshWithCompletion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange:)
                                                 name:kLoggedInChangedNotification
                                               object:[VObjectManager sharedManager]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([AgeGate isAnonymousUser])
    {
        UIBarButtonItem *legalInfoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"D_more"] style:UIBarButtonItemStylePlain target:self action:@selector(showLegalInfoOptions)];
        NSMutableArray *leftItems = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
        [leftItems addObject:legalInfoButton];
        [self.navigationItem setLeftBarButtonItems:leftItems];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLoggedInChangedNotification
                                                  object:[VObjectManager sharedManager]];
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    [self.streamDataSource unloadStream];
    if ( [VObjectManager sharedManager].mainUserLoggedIn )
    {
        [self refreshWithCompletion:nil];
    }
}

- (void)refreshWithCompletion:(void(^)(void))completionBlock
{
    [super refreshWithCompletion:^
     {
         [self dataSourceDidRefresh];
         
         if ( completionBlock != nil )
         {
             completionBlock();
         }
     }];
}

- (void)dataSourceDidRefresh
{
    if ( self.streamDataSource.count == 0 && !self.streamDataSource.hasHeaderCell )
    {
        if ( self.noContentView == nil )
        {
            VNoContentView *noContentView = [VNoContentView noContentViewWithFrame:self.collectionView.frame];
            if ( [noContentView respondsToSelector:@selector(setDependencyManager:)] )
            {
                noContentView.dependencyManager = self.dependencyManager;
            }
            noContentView.title = NSLocalizedString( @"NotFollowingTitle", @"" );
            noContentView.message = NSLocalizedString( @"NotFollowingMessage", @"" );
            noContentView.icon = [UIImage imageNamed:@"noFollowersIcon"];
            self.noContentView = noContentView;
        }
        
        self.collectionView.backgroundView = self.noContentView;
    }
    else
    {
        self.collectionView.backgroundView = nil;
    }
}

#pragma mark - Anonymous User Actions

- (void)showLegalInfoOptions
{
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    
    VActionSheetViewController *actionSheetViewController = [VActionSheetViewController actionSheetViewController];
    actionSheetViewController.dependencyManager = self.dependencyManager;
    
    [VActionSheetTransitioningDelegate addNewTransitioningDelegateToActionSheetController:actionSheetViewController];
    // Compose a terms of service action item
    VActionItem *tosItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"ToSText", "")
                                                        actionIcon:nil
                                                        detailText:nil];
    tosItem.selectionHandler = ^(VActionItem *item)
    {
        [actionSheetViewController dismissViewControllerAnimated:YES completion:^
         {
             [self presentViewController:[VTOSViewController presentableTermsOfServiceViewController] animated:YES completion:nil];
         }];
    };
    
    [actionItems addObject:tosItem];
    
    // Compose a privacy policies action item
    VActionItem *privacyItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Privacy Policy", "")
                                                        actionIcon:nil
                                                        detailText:nil];
    privacyItem.selectionHandler = ^(VActionItem *item)
    {
        [actionSheetViewController dismissViewControllerAnimated:YES completion:^
         {
             [self presentViewController:[VPrivacyPoliciesViewController presentableTermsOfServiceViewControllerWithDependencyManager:self.dependencyManager] animated:YES completion:nil];
         }];
    };
    
    [actionItems addObject:privacyItem];
    
    [actionSheetViewController addActionItems:actionItems];
    [self presentViewController:actionSheetViewController animated:YES completion:nil];
}

@end
