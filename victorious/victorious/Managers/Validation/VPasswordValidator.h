//
//  VPasswordValidator.h
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VStringValidator.h"

extern NSInteger const VErrorCodeCurrentPasswordIsIncorrect;
extern NSInteger const VErrorCodeCurrentPasswordIsInvalid;
extern NSInteger const VErrorCodeInvalidPasswordEntered;
extern NSInteger const VErrorCodeInvalidPasswordsDoNotMatch;
extern NSInteger const VErrorCodeInvalidPasswordsNewEqualsCurrent;

@interface VPasswordValidator : VStringValidator

@property (nonatomic, strong) NSString *currentPassword;

@end
