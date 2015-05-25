//
//  VLoginFlowControllerResponder.h
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLoginFlowControllerResponder <NSObject>

- (void)cancelLoginAndRegistration;

- (void)selectedLogin;

- (void)selectedRegister;

- (void)selectedTwitterAuthorizationWithCompletion:(void(^)(BOOL success))completion;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void(^)(BOOL success, NSError *error))completion;

- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
               completion:(void(^)(BOOL success, NSError *error))completion;

@end
