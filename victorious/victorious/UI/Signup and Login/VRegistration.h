//
//  VRegistration.h
//  victorious
//
//  Created by Patrick Lynch on 3/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#warning Rename this file to something else

@protocol VRegistrationViewControllerDelegate

- (void)didFinishRegistrationStepWithSuccess:(BOOL)success;

@end

@protocol VRegistrationViewController <NSObject>

#warning rename this to something else more specific
@property (nonatomic, weak) id<VRegistrationViewControllerDelegate> delegate;

@end