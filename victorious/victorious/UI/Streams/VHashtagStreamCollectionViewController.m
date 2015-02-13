//
//  VHashtagStreamCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagStreamCollectionViewController.h"
#import "UIViewController+VNavMenu.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VObjectManager+Discover.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VAuthorizationViewControllerFactory.h"
#import "MBProgressHUD.h"
#import "VObjectManager+Sequence.h"
#import "VStream+Fetcher.h"

@interface VHashtagStreamCollectionViewController ()

@property (nonatomic, assign) BOOL isSubscribedToHashtag;
@property (nonatomic, strong) NSString *selectedHashtag;
@property (nonatomic, weak) MBProgressHUD *failureHUD;

@end

@implementation VHashtagStreamCollectionViewController

+ (instancetype)instantiateWithHashtag:(NSString *)hashtag
{
    VHashtagStreamCollectionViewController *streamCollection = [[self class] streamViewControllerForStream:[VStream streamForHashTag:hashtag]];
    streamCollection.selectedHashtag = hashtag;
    return streamCollection;
}

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    NSString *identifier = NSStringFromClass([VHashtagStreamCollectionViewController class]);
    VHashtagStreamCollectionViewController *streamCollection = (VHashtagStreamCollectionViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:identifier];
    streamCollection.currentStream = stream;
    return streamCollection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchHashtagsForLoggedInUser];
}

#pragma mark - Fetch Users Tags

- (void)fetchHashtagsForLoggedInUser
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self updateHashtagNavButton];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"%@\n%@", operation, error);
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeFirst
                                                           perPageLimit:1000
                                                           successBlock:successBlock
                                                              failBlock:failureBlock];
}

- (void)refreshWithCompletion:(void (^)(void))completionBlock
{
    [super refreshWithCompletion:^
     {
         [self updateHashtagNavButton];
     }];
}

- (void)updateHashtagNavButton
{
    NSAssert( self.selectedHashtag != nil, @"Houston, we have an issue." );
    NSAssert( self.selectedHashtag.length > 0, @"Houston, we have an issue." );
    
    NSString *buttonImageName = @"streamFollowHashtag";
    BOOL subscribed = NO;
    
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag == %@", self.selectedHashtag];
    VHashtag *hashtag = [mainUser.hashtags filteredOrderedSetUsingPredicate:predicate].firstObject;
    if ( hashtag != nil )
    {
        buttonImageName = @"followedHashtag";
        subscribed = YES;
    }
    
    UIImage *hashtagButtonImage = [[UIImage imageNamed:buttonImageName]  imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.navHeaderView setRightButtonImage:hashtagButtonImage withAction:@selector(followUnfollowHashtagButtonAction:) onTarget:nil];
    self.isSubscribedToHashtag = subscribed;
}

#pragma mark - Hashtag Button Actions

- (void)followUnfollowHashtagButtonAction:(UIButton *)sender
{
    // Check if logged in before attempting to subscribe / unsubscribe
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    // Disable the sub/unsub button
    sender.userInteractionEnabled = NO;
    sender.alpha = 0.3f;
    
    if (self.isSubscribedToHashtag)
    {
        [self unfollowHashtagAction:sender];
    }
    else
    {
        [self followHashtagAction:sender];
    }
}

- (void)followHashtagAction:(UIButton *)sender
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Animate follow button
        self.isSubscribedToHashtag = YES;
        [self updateSubscribeStatusAnimated:YES button:sender];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHUD.mode = MBProgressHUDModeText;
        self.failureHUD.detailsLabelText = NSLocalizedString(@"HashtagSubscribeError", @"");
        [self.failureHUD hide:YES afterDelay:3.0f];
        
        // Set button back to normal state
        sender.userInteractionEnabled = YES;
        sender.alpha = 1.0f;
    };
    
    // Backend Subscribe to Hashtag call
    [[VObjectManager sharedManager] subscribeToHashtag:self.selectedHashtag
                                          successBlock:successBlock
                                             failBlock:failureBlock];
}

- (void)unfollowHashtagAction:(UIButton *)sender
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        self.isSubscribedToHashtag = NO;
        [self updateSubscribeStatusAnimated:YES button:sender];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHUD.mode = MBProgressHUDModeText;
        self.failureHUD.detailsLabelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
        [self.failureHUD hide:YES afterDelay:3.0f];
        
        // Set button back to normal state
        sender.userInteractionEnabled = YES;
        sender.alpha = 1.0f;
    };
    
    // Backend Unsubscribe to Hashtag call
    [[VObjectManager sharedManager] unsubscribeToHashtag:self.selectedHashtag
                                            successBlock:successBlock
                                               failBlock:failureBlock];
}

#pragma mark - Follow / Unfollow Hashtag Completion Method

- (void)updateSubscribeStatusAnimated:(BOOL)animated button:(UIButton *)sender
{
    NSString *buttonImageName = @"streamFollowHashtag";
    
    if (self.isSubscribedToHashtag)
    {
        buttonImageName = @"followedHashtag";
    }
    
    // Reset the hashtag button image
    // TODO
    //    UIImage *hashtagButtonImage = [[UIImage imageNamed:buttonImageName] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //    [self.navHeaderView setRightButtonImage:hashtagButtonImage withAction:nil onTarget:nil];
    
    
    // Set button back to normal state
    sender.userInteractionEnabled = YES;
    sender.alpha = 1.0f;
    
    // Fire NSNotification to signal change in the status of this hashtag
    [[NSNotificationCenter defaultCenter] postNotificationName:kHashtagStatusChangedNotification
                                                        object:nil];
}

@end
