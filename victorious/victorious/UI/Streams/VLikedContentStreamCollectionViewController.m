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
@property (nonatomic, strong) NSMutableArray *streamItemsToRemove;

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
    
    // Remove any cells which we've unliked
    for (VStreamItem *streamItem in self.streamItemsToRemove)
    {
        [self.streamDataSource removeStreamItem:streamItem];
    }
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

- (NSMutableArray *)streamItemsToRemove
{
    if (_streamItemsToRemove == nil)
    {
        _streamItemsToRemove = [NSMutableArray new];
    }
    
    return _streamItemsToRemove;
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
            noContentView.title = NSLocalizedString( @"NOTHING LIKED YET", @"" );
            noContentView.message = NSLocalizedString( @"Posts you like will appear here.", @"" );
            noContentView.icon = [UIImage imageNamed:@"liked_stream_empty"];
            self.noContentView = noContentView;
            [(VNoContentView *)self.noContentView resetInitialAnimationState];
        }
        
        self.collectionView.backgroundView = self.noContentView;
        [(VNoContentView *)self.noContentView animateTransitionIn];
    }
    else
    {
        self.collectionView.backgroundView = nil;
    }
}

- (void)willLikeSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion
{
    __weak typeof(self) welf = self;
    [super willLikeSequence:sequence withView:view completion:^(BOOL success)
    {
        __strong typeof(self) strongSelf = welf;
        NSIndexPath *likedIndexPath = [strongSelf.streamDataSource indexPathForItem:sequence];
        
        if (likedIndexPath != nil && success)
        {
            // Save cell index path for removal
            if (!sequence.isLikedByMainUser.boolValue)
            {
                [strongSelf.streamItemsToRemove addObject:sequence];
            }
            else if ([strongSelf.streamItemsToRemove containsObject:sequence])
            {
                [strongSelf.streamItemsToRemove removeObject:sequence];
            }
        }
        
        if (completion != nil)
        {
            completion(success);
        }
    }];
}

@end
