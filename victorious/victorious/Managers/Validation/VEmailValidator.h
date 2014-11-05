//
//  VEmailValidator.h
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VValidator.h"

extern NSInteger const VSignupErrorCodeInvalidEmailAddress;

@interface VEmailValidator : VValidator

- (BOOL)validateEmailAddress:(NSString *)emailAddress error:(NSError **)outError;

@end
