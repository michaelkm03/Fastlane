//
//  VAuthorizationProvider.h
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 By conforming to this protocol, an object assures it will provide some kind
 of authorization process, at the end of which the `authorizedAction` properpty block
 will be called.  This allows calling code to encapsulate authorized-only functionality
 in that block to be stored through the authorization proceess and called only if
 authorization was completed.
 */
@protocol VAuthorizationProvider <NSObject>

/**
 The action the user is attempting to perform, stored with any object that is
 providing an authorization process.
 */
@property (nonatomic, copy) void (^authorizedAction)();

@end