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

@interface VFollowingStreamCollectionViewController ()

@property (nonatomic, strong) VNoContentView *noContentView;

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
                                               object:[VObjectManager sharedManager]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLoggedInChangedNotification
                                                  object:[VObjectManager sharedManager]];
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    [self refreshWithCompletion:nil];
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
    if ( self.streamDataSource.count == 0 )
    {
        if ( self.noContentView == nil )
        {
            self.noContentView = [VNoContentView noContentViewWithFrame:self.collectionView.frame];
            self.noContentView.titleLabel.text = NSLocalizedString( @"NotFollowingTitle", @"" );
            self.noContentView.messageLabel.text = NSLocalizedString( @"NotFollowingMessage", @"" );
            self.noContentView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        }
        
        self.collectionView.backgroundView = self.noContentView;
    }
    else
    {
        self.collectionView.backgroundView = nil;
    }
}

@end