//
//  VEmailValidator.h
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VValidator.h"

static NSUInteger const kVSignupErrorCodeBadUsername      = 5100;
static NSUInteger const kVSignupErrorCodeBadPassword      = 5101;
static NSUInteger const kVSignupErrorCodeBadEmailAddress  = 5102;

@interface VEmailValidator : VValidator

- (BOOL)validateEmailAddress:(NSString *)emailAddress error:(NSError **)outError;

@end
