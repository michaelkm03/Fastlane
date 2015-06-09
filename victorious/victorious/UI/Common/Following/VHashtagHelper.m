//
//  VHashtagHelper.m
//  victorious
//
//  Created by Steven F Petteruti on 6/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagHelper.h"
#import "VUser.h"
#import "VObjectManager.h"
#import "VObjectManager+Discover.h"
#import "VAbstractFilter+RestKit.h"
#import "MBProgressHUD.h"

@interface VHashtagHelper ()

@property (nonatomic, weak) MBProgressHUD *failureHud;

@end



@implementation VHashtagHelper

- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(void))success failureBlock:(void (^)(void))failure
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    if (mainUser.hashtags.count == 0)
    {
        [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeFirst perPageLimit:1000
                                                               successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                                   successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
              {
                  success();
              }
                                                      failBlock:^(NSOperation *operation, NSError *error)
              {
                  failure();
                  
                  
              }];
             
         } failBlock:^(NSOperation *operation, NSError *error)
         {
             failure();
         }];
    }
    else
    {
        [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             success();
         }
                                                 failBlock:^(NSOperation *operation, NSError *error)
         {
             failure();
             
         }];
    }
}

- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(void))success failureBlock:(void (^)(void))failure
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    if (mainUser.hashtags.count == 0)
    {
        [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeFirst perPageLimit:1000
                                                               successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                                     successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
              {
                  success();
              }
                                                        failBlock:^(NSOperation *operation, NSError *error)
              {
                  failure();
              }];
             
         } failBlock:^(NSOperation *operation, NSError *error)
         {
             failure();
         }];
    }
    else
    {
        [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                                successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             success();
         }
                                                 failBlock:^(NSOperation *operation, NSError *error)
         {
             failure();
         }];
    }
}


- (void)showFailureHUD
{
    /*
     self.failureHud = [MBProgressHUD showHUDAddedTo:view animated:YES];
     self.failureHud.mode = MBProgressHUDModeText;
     self.failureHud.labelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
     [self.failureHud hide:YES afterDelay:3.0f];*/
}

@end
