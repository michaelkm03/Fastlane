//
//  VExperienceEnhancerResponder.h
//  victorious
//
//  Created by Patrick Lynch on 7/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VExperienceEnhancerResponder <NSObject>

- (void)showPurchaseViewController:(VVoteType *)voteType;

- (void)authorizeWithCompletion:(void(^)(BOOL))completion;

@end
