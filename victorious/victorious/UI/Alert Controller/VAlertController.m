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

static const BOOL kForceBasicAlertController = NO;

@interface VAlertController ()

@property (nonatomic, readwrite, strong) NSString *title;
@property (nonatomic, readwrite, strong) NSString *message;
@property (nonatomic, readwrite, assign) VAlertControllerStyle style;

@end

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

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style
{
    self = [super init];
    if (self)
    {
        _style = style;
        _title = title;
        _message = message;
    }
    return self;
}

+ (BOOL)canUseAlertController
{
    return NSClassFromString( @"UIAlertController" ) != nil && !kForceBasicAlertController;
}

- (void)addAction:(VAlertAction *)action
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

- (void)removeAllActions
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    NSAssert( NO, @"This method must be overidden in a subclass." );
}

@end