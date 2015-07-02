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
#import "NSString+VParseHelp.h"
#import "VDependencyManager+VObjectManager.h"
#import "VStream+Fetcher.h"
#import "VObjectManager+Pagination.h"

@interface VLikedContentStreamCollectionViewController ()

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
    
    NSLog(@"view loaded");
}

- (void)refreshWithCompletion:(void (^)(void))completionBlock
{
    [super refreshWithCompletion:^
     {
         [self dataSourceDidRefresh];
     }];
}

- (void)dataSourceDidRefresh
{
    if ( self.streamDataSource.count == 0 )
    {
        if ( self.noContentView == nil )
        {
            VNoContentView *noContentView = [VNoContentView noContentViewWithFrame:self.collectionView.frame];
            if ( [noContentView respondsToSelector:@selector(setDependencyManager:)] )
            {
                noContentView.dependencyManager = self.dependencyManager;
            }
            noContentView.title = NSLocalizedString( @"Haven't liked anything", @"" );
            noContentView.message = NSLocalizedString( @"You can't liked any posts lol", @"" );
            noContentView.icon = [UIImage imageNamed:@"tabIconHashtag"];
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
