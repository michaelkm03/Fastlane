//
//  VAuthorizationContextHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationContext.h"
                
@interface VAuthorizationContextHelper : NSObject

/**
 Returns localized text intended to display to the user when the login/registration
 prompt appears according to the specified context.
 */
- (NSString *)textForContext:(VAuthorizationContext)context;

@end
