//
//  VDependencyManager+VLoginAndRegistration.h
//  victorious
//
//  Created by Patrick Lynch on 6/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VScreenPromptKey;
extern NSString * const VScreenSuccessMessageKey;
extern NSString * const VButtonPromptKey;
extern NSString * const VButtonSuccessMessageKey;
extern NSString * const VShouldRequestCameraPermissionsKey;
extern NSString * const VDisplayWithSocialRegistration;

@interface VDependencyManager (VLoginAndRegistration)

/**
 If NO, Facebook's own server configuration should determine whether or not we use
 Facebook native login. If YES, we should always use it if available.
 */
- (BOOL)shouldForceNativeFacebookLogin;

@end
