//
//  VFollowersDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFollowersDataSource.h"
#import "VUser.h"
#import "VConstants.h"
#import "MBProgressHUD.h"
#import "victorious-Swift.h"

@interface VFollowersDataSource ()

@property (nonatomic, strong) VUser *user;
@property (nonatomic, strong) NSMutableOrderedSet *followersForUser;
@property (nonatomic, strong) PageLoader *pageLoader;

@end

@implementation VFollowersDataSource

- (instancetype)initWithUser:(VUser *)user
{
    NSParameterAssert( user != nil );
    
    self = [super init];
    if ( self != nil )
    {
        _user = user;
        _pageLoader = [[PageLoader alloc] init];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - VUsersDataSource

- (NSString *)noContentTitle
{
    return self.user.isCurrentUser  ? NSLocalizedString( @"NoFollowersTitle", @"" ) : NSLocalizedString( @"ProfileNoFollowersTitle", @"" );
}

- (NSString *)noContentMessage
{
    return self.user.isCurrentUser ? NSLocalizedString( @"NoFollowersMessage", @"" ) : NSLocalizedString( @"ProfileNoFollowersMessage", @"" );
}

- (UIImage *)noContentImage
{
    return [UIImage imageNamed:@"noFollowersIcon"];
}


- (void)refreshWithPageType:(VPageType)pageType completion:(void(^)(BOOL success, NSError *error))completion
{
    [_pageLoader loadPage:pageType createOperation:^RequestOperation *_Nonnull
     {
         return [[FollowersOfUserOperation alloc] initWithUserID:self.user.remoteId.longLongValue];
     }
               completion:^(RequestOperation *_Nonnull operation, NSError *_Nullable error)
     {
         if ( error == nil )
         {
             FollowersOfUserOperation *followersOperation = (FollowersOfUserOperation *)operation;
             if ( pageType == VPageTypeFirst )
             {
                 // Start fresh on the first page
                 [self.followersForUser removeAllObjects];
             }
             [self.followersForUser addObjectsFromArray:followersOperation.loadedUsers];
         }
         
         if ( completion != nil )
         {
             completion( error != nil, error );
         }
     }];
}

- (NSArray *)users
{
    return self.followersForUser.array;
}

@end
