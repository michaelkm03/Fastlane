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

+ (VTwitterManager *)sharedManager;

- (BOOL)isLoggedIn;

/**
 *  Does a twitter reverse oauth and stores the information in the class properties
 *
 *  @param identifier      The identifier for the account to use.  May be nil.
 *  @param completionBlock Block that will run after completing.
 */
- (void)refreshTwitterTokenWithIdentifier:(NSString *)identifier
                          completionBlock:(void(^)(void))completionBlock;

@end
