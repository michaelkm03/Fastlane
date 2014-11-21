//
//  VAlertController.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAlertController.h"
#import "VAlertControllerAdvanced.h"
#import "VAlertControllerBasic.h"

@implementation VAlertController

+ (VAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style
{
    if ( [VAlertController canUseAlertController] )
    {
        return [[VAlertControllerAdvanced alloc] initWithTitle:title message:message style:style];
    }
    else
    {
        return [[VAlertControllerBasic alloc] initWithTitle:title message:message style:style];
    }
    
    return nil;
}

+ (BOOL)canUseAlertController
{
    return NSClassFromString( @"UIAlertController" ) != nil;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
    
    return nil;
}

- (void)addAction:(VAlertAction *)action
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

@end