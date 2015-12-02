//
//  VFollowingStreamCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowingStreamCollectionViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VNoContentView.h"
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
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLoggedInChangedNotification
                                                  object:nil];
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    [self.streamDataSource unloadStream];
    if ( [VUser currentUser] != nil )
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

@end
