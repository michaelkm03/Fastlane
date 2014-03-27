//
//  VUserManager.h
//  victorious
//
//  Created by Gary Philipp on 2/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

NS_ENUM(NSInteger, LoginType)
{
    kLoginTypeNone,
    kLoginTypeEmail,
    kLoginTypeFacebook,
    kLoginTypeTwitter
};

@interface VUserManager : NSObject

+ (VUserManager *)sharedInstance;

- (void)silentlyLogin;
- (void)logout;

@end
