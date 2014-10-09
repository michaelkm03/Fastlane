//
//  VPasswordValidator.h
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VAccountUpdateViewControllerErrorCode)
{
    VAccountUpdateViewControllerBadPasswordErrorCode
};

@interface VPasswordValidator : NSObject

+ (BOOL)validatePassword:(NSString *)password error:(NSError **)outError;

+ (BOOL)validatePassword:(NSString *)password confirmation:(NSString *)confirmationPassword;

@end
