//
//  VLoginRegistrationFlow.h
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  VLoginFlowCompletionBlock is a completion block for VLoginFlow conformers to call upon completion.
 *  The authorized parameter should inform calling code of whether or not the user is now logged in.
 */
typedef void (^VLoginFlowCompletionBlock) (BOOL authorized);

/**
 *  Objects conforming to this protocol provide UI for the user to login or register.
 */
@protocol VLoginRegistrationFlow <NSObject>

/**
 *  A completion block to be called after the completion of the flow. Protocol conformers must call this 
 *  when they are finished.
 */
@property (nonatomic, copy) VLoginFlowCompletionBlock onCompletionBlock;

@end
