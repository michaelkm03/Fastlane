//
//  VUserIsFollowingDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserIsFollowingDataSource.h"
#import "VUser.h"
#import "VConstants.h"
#import "MBProgressHUD.h"
#import "victorious-Swift.h"

@interface VUserIsFollowingDataSource ()

@property (nonatomic, strong) NSMutableOrderedSet *followedUsers;

@end

@implementation VUserIsFollowingDataSource

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
    return self.user.isCurrentUser ? NSLocalizedString( @"NotFollowingTitle", @"" ) : NSLocalizedString( @"ProfileNotFollowingTitle", @"" );
}

- (NSString *)noContentMessage
{
    return self.user.isCurrentUser ? NSLocalizedString( @"NotFollowingMessage", @"" ) : NSLocalizedString( @"ProfileNotFollowingMessage", @"" );
}

- (UIImage *)noContentImage
{
    return [UIImage imageNamed:@"noFollowersIcon"];
}

- (void)refreshWithPageType:(VPageType)pageType completion:(void(^)(BOOL success, NSError *error))completion
{
    [self loadPage:pageType completion:^(NSArray<VUser *> *_Nonnull users, NSError *_Nullable error)
    {
        if ( error == nil )
        {
            if ( pageType == VPageTypeFirst )
            {
                // Start fresh on the first page
                [self.followedUsers removeAllObjects];
            }
            [self.followedUsers addObjectsFromArray:users];
        }
    }];
}

- (NSArray *)users
{
    return self.followedUsers.array;
}

@end
