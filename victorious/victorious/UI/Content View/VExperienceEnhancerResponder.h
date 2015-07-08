//
//  VExperienceEnhancerResponder.h
//  victorious
//
//  Created by Patrick Lynch on 7/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Responder to handle events from experience enhancer/emotive ballistics UI.
 */
@protocol VExperienceEnhancerResponder <NSObject>

/**
 Presents a view controller in the appropriate place in the view controller
 hierarcy that will take the user through purchasing the VVoteType instance provided.
 */
- (void)showPurchaseViewController:(VVoteType *)voteType;

/**
 Presents a login/signup view controller in the appropriate place in the view
 controller hierarchy and calls the completion block when the process
 is complete.  The BOOL parameter of the completion block indicates whether
 or not the user completed the authorization process suggessfully and is now
 logged in.
 */
- (void)authorizeWithCompletion:(void(^)(BOOL))completion;

@end
