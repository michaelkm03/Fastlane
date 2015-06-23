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
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VAuthorizedAction.h"

@interface VUserIsFollowingDataSource ()

@property (nonatomic, strong) VUser *user;
@property (nonatomic, strong) NSArray *followedUsers;

@end

@implementation VUserIsFollowingDataSource

- (instancetype)initWithUser:(VUser *)user
{
    NSParameterAssert( user != nil );
    
    self = [super init];
    if ( self != nil )
    {
        _user = user;
    }
    return self;
}

#pragma mark - VUsersDataSource

- (NSString *)noContentTitle
{
    const BOOL isCurrentUser = [[VObjectManager sharedManager].mainUser isEqual:self.user];
    return isCurrentUser ? NSLocalizedString( @"ProfileNotFollowingTitle", @"" ) : NSLocalizedString( @"NotFollowingTitle", @"" );
}

- (NSString *)noContentMessage
{
    const BOOL isCurrentUser = [[VObjectManager sharedManager].mainUser isEqual:self.user];
    return isCurrentUser ? NSLocalizedString( @"ProfileNotFollowingMessage", @"" ) : NSLocalizedString( @"NotFollowingMessage", @"" );
}

- (UIImage *)noContentImage
{
    return [UIImage imageNamed:@"noFollowersIcon"];
}

- (void)refreshWithPageType:(VPageType)pageType completion:(void(^)(BOOL success, NSError *error))completion
{
    
    [[VObjectManager sharedManager] loadFollowingsForUser:self.user pageType:pageType
                                             successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if ( pageType == VPageTypeFirst )
         {
             self.followedUsers = @[];
         }
         
         NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
         self.followedUsers = [[self.followedUsers arrayByAddingObjectsFromArray:resultObjects] sortedArrayUsingDescriptors:@[ sort ]];
         
         completion( YES, nil );
     }
                                               failBlock:^(NSOperation *operation, NSError *error)
     {
         completion( NO, error );
     }];
}

- (NSArray *)users
{
    return self.followedUsers;
}

@end
