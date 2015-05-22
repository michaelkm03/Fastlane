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

@end
