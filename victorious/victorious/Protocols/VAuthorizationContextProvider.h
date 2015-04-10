//
//  VAuthorizationContextProvider.h
//  victorious
//
//  Created by Michael Sena on 4/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAuthorizationContext.h"

/**
 *  Objects that requires authorization to function should implement this procotol 
 *  to inform callers about this requirement.
 */
@protocol VAuthorizationContextProvider <NSObject>

@required

/**
 *  Returning YES informs callers that this object requires authorizaiton to behave appropriately.
 */
- (BOOL)requiresAuthorization;

/**
 *  Lets calling code know about any associated authorization context that is required
 *  in order to navigate to this desination.  Leave this method unimplemented, or return
 *  VAuthorizationContextNone to skip authorization for this destination.
 */
- (VAuthorizationContext)authorizationContext;

@end
