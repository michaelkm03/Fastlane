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

- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure
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
                  if (success != nil)
                  {
                      success(resultObjects);
                  }
              }
                                                      failBlock:^(NSOperation *operation, NSError *error)
              {
                  if (failure != nil)
                  {
                      failure(error);
                  }
              }];
             
         } failBlock:^(NSOperation *operation, NSError *error)
         {
             if (failure != nil)
             {
                 failure(error);
             }
         }];
    }
    else
    {
        [[VObjectManager sharedManager] subscribeToHashtag:hashtag
                                              successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             if (success != nil)
             {
                 success(resultObjects);
             }
         }
                                                 failBlock:^(NSOperation *operation, NSError *error)
         {
             if (failure != nil)
             {
                 failure(error);
             }
         }];
    }
}

- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure
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
                  if (success != nil)
                  {
                      success(resultObjects);
                  }
              }
                                                        failBlock:^(NSOperation *operation, NSError *error)
              {
                  if (failure != nil)
                  {
                      failure(error);
                  }
              }];
             
         } failBlock:^(NSOperation *operation, NSError *error)
         {
             failure(error);
         }];
    }
    else
    {
        [[VObjectManager sharedManager] unsubscribeToHashtag:hashtag
                                                successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             if (success != nil)
             {
                 success(resultObjects);
             }
         }
                                                   failBlock:^(NSOperation *operation, NSError *error)
         {
             if (failure != nil)
             {
                 failure(error);
             }
         }];
    }
}

@end
