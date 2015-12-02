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
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VObjectManager.h"

@interface VFollowersDataSource ()

@property (nonatomic, strong) VUser *user;
@property (nonatomic, strong) NSArray *followersForUser;

@end

@implementation VFollowersDataSource

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

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - VUsersDataSource

- (NSString *)noContentTitle
{
    const BOOL isCurrentUser = [[VObjectManager sharedManager].mainUser isEqual:self.user];
    return isCurrentUser ? NSLocalizedString( @"NoFollowersTitle", @"" ) : NSLocalizedString( @"ProfileNoFollowersTitle", @"" );
}

- (NSString *)noContentMessage
{
    const BOOL isCurrentUser = [[VObjectManager sharedManager].mainUser isEqual:self.user];
    return isCurrentUser ? NSLocalizedString( @"NoFollowersMessage", @"" ) : NSLocalizedString( @"ProfileNoFollowersMessage", @"" );
}

- (UIImage *)noContentImage
{
    return [UIImage imageNamed:@"noFollowersIcon"];
}

- (void)refreshWithPageType:(VPageType)pageType completion:(void(^)(BOOL success, NSError *error))completion
{
    
    [[VObjectManager sharedManager] loadFollowersForUser:self.user pageType:pageType
                                             successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         if ( pageType == VPageTypeFirst )
         {
             self.followersForUser = @[];
         }
         
         self.followersForUser = [self.followersForUser arrayByAddingObjectsFromArray:resultObjects];
         
         completion( YES, nil );
     }
                                                failBlock:^(NSOperation *operation, NSError *error)
     {
         completion( NO, error );
     }];
}

- (NSArray *)users
{
    return self.followersForUser;
}

@end
