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
#import "VDependencyManager+VAccessoryScreens.h"
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange:)
                                                 name:kLoggedInChangedNotification
                                               object:nil];
    
    self.noContentView.title = NSLocalizedString( @"NotFollowingTitle", @"" );
    self.noContentView.message = NSLocalizedString( @"NotFollowingMessage", @"" );
    self.noContentView.icon = [UIImage imageNamed:@"noFollowersIcon"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLoggedInChangedNotification
                                                  object:nil];
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    if ( [VCurrentUser user] != nil )
    {
        [self loadPage:VPageTypeFirst completion:nil];
    }
    else
    {
        [self.streamDataSource.paginatedDataSource unload];
    }
}

@end
