//
//  VLikedContentStreamCollectionViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLikedContentStreamCollectionViewController.h"
#import "VNoContentView.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VObjectManager+Login.h"

@interface VLikedContentStreamCollectionViewController ()

@property (nonatomic, assign) BOOL shouldRefreshOnView;

@end

@implementation VLikedContentStreamCollectionViewController

#pragma mark - Factory methods

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    NSString *identifier = NSStringFromClass([VLikedContentStreamCollectionViewController class]);
    VLikedContentStreamCollectionViewController *streamCollection = (VLikedContentStreamCollectionViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:identifier];
    streamCollection.currentStream = stream;
    return streamCollection;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldRefreshOnView = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange:)
                                                 name:kLoggedInChangedNotification
                                               object:[VObjectManager sharedManager]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.shouldRefreshOnView )
    {
        [self refreshWithCompletion:nil];
        self.shouldRefreshOnView = NO;
    }
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    [self.streamDataSource unloadStream];
    self.shouldRefreshOnView = YES;
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
            noContentView.title = NSLocalizedString( @"No Likes", @"" );
            noContentView.message = NSLocalizedString( @"You haven't liked anything yet!", @"" );
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

@end
