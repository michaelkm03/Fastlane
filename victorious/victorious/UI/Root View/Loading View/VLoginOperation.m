//
//  VLoginOperation.m
//  victorious
//
//  Created by Josh Hinman on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoginOperation.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"

@interface VLoginOperation ()

@property (nonatomic, strong, readonly) dispatch_semaphore_t semaphore;

@end

@implementation VLoginOperation

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)main
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        // First try to log in with stored user (token from keychain)
        const BOOL loginWithStoredUserDidSucceed = [[VObjectManager sharedManager] loginWithExistingToken];
        if ( loginWithStoredUserDidSucceed )
        {
            dispatch_semaphore_signal(self.semaphore);
        }
        else
        {
            // Log in through server using saved password
            [[VUserManager sharedInstance] loginViaSavedCredentialsOnCompletion:^(VUser *user, BOOL created)
            {
                dispatch_semaphore_signal(self.semaphore);
            }
                                                                       onError:^(NSError *error, BOOL thirdPartyAPIFailed)
            {
                dispatch_semaphore_signal(self.semaphore);
            }];
        }
    });
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

@end
