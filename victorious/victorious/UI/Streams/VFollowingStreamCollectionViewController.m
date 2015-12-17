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
        [self addLegalInfoButton];
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

- (void)addLegalInfoButton
{
    UIBarButtonItem *legalInfoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"D_more"] style:UIBarButtonItemStylePlain target:self action:@selector(showLegalInfoOptions)];
    NSMutableArray *leftItems = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
    [leftItems addObject:legalInfoButton];
    [self.navigationItem setLeftBarButtonItems:leftItems];
}

- (void)showLegalInfoOptions
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *tosAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ToSText", "")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        [self presentViewController:[VTOSViewController presentableTermsOfServiceViewController] animated:YES completion:nil];
    }];
    UIAlertAction *privacyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Privacy Policy", "")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
    {
        [self presentViewController:[VPrivacyPoliciesViewController presentableTermsOfServiceViewControllerWithDependencyManager:self.dependencyManager] animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:tosAction];
    [alert addAction:privacyAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
