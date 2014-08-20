//
//  VTwitterManager.h
//  victorious
//
//  Created by Will Long on 8/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTwitterManager : NSObject

@property (nonatomic, readonly) NSString* oauthToken;
@property (nonatomic, readonly) NSString* secret;
@property (nonatomic, readonly) NSString* twitterId;

- (BOOL)isLoggedIn;

- (void)refreshTwitterTokens;

@end
