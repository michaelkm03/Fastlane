//
//  VAlertAction.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAlertAction.h"

@implementation VAlertAction

+ (VAlertAction *)cancelButtonWithTitle:(NSString *)title handler:(void(^)(VAlertAction *))handler
{
    return [[VAlertAction alloc] initWithTitle:title style:VAlertActionStyleCancel handler:handler];
}

+ (VAlertAction *)buttonWithTitle:(NSString *)title handler:(void(^)(VAlertAction *))handler
{
    return [[VAlertAction alloc] initWithTitle:title style:VAlertActionStyleDefault handler:handler];
}

+ (VAlertAction *)destructiveButtonWithTitle:(NSString *)title handler:(void(^)(VAlertAction *))handler
{
    return [[VAlertAction alloc] initWithTitle:title style:VAlertActionStyleDestructive handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(VAlertActionStyle)style handler:(void(^)(VAlertAction *))handler
{
    self = [super init];
    if (self)
    {
        _title = title;
        _style = style;
        _handler = handler;
        _enabled = YES;
    }
    return self;
}

- (void)execute
{
    if ( self.handler != nil )
    {
        self.handler( self );
    }
}

@end