//
//  VFollowUserResponder.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VFollowUserResponderCompletion)(BOOL isFollowing);

@class VUser;

/**
 *  Conformers to this protocol provide handling of following users. Conformers should be in the responder chain.
 */
@protocol VFollowUserResponder <NSObject>
#error FINISH & USE ME
- (void)followUser:(VUser *)user
            sender:(id)sender
        completion:(VFollowUserResponderCompletion)completion;

@end
