//
//  VRegistration.h
//  victorious
//
//  Created by Patrick Lynch on 3/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/**
 The protocols defined in this file are designed to work together to connect various
 registration steps into a single process that can be managed easily.
 */

/**
 Objects conforming to this protocol are usually instanting an object that conforms to
 VRegistrationStep and setting themselves at the `registrationDelegate` property.  This allows
 the VRegistrationStep instance to call `didFinishRegistrationStepProcessWithSuccess:` when 
 its process is complete.  This relationship can be repeated across many objects, creating a 
 chain of linked steps that can propogate their completion message back to the start of the chain.
 */
@protocol VRegistrationStepDelegate

/**
 Provides an implementation that handles completion of a registration step, such as
 updating any date received by the registration step process or dismissing a view controller
 hat conforms to VRegistrationStep and was presented to collect user information.
 */
- (void)didFinishRegistrationStepWithSuccess:(BOOL)success;

@end

/**
 Objects conforming to this protocol will perform some process or action involved
 in the registration larger registration process.  Typically this is a view controller
 that receives input from the user and performs a network request.  The `registrationStepDelegate`
 property should be define when insantiating such an object so that when the registration
 step process is complete, the delegate method `didFinishRegistrationStepProcessWithSuccess:`
 is called to signal back to its creator.  In this way, multuple conformers to VRegistrationStep
 can be chained together.
 */
@protocol VRegistrationStep <NSObject>

@property (nonatomic, weak) id<VRegistrationStepDelegate> registrationStepDelegate;

@end