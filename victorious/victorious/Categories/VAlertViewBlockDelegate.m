//
//  VAlertViewBlockDelegate.m
//  victorious
//
//  Created by Josh Hinman on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAlertViewBlockDelegate.h"

@implementation VAlertViewBlockDelegate

- (id)initWithCancelBlock:(void(^)(void))cancelBlock
{
    self = [super init];
    if (self)
    {
        self.onCancel = cancelBlock;
        _otherButtonHandlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        if (self.onCancel)
        {
            self.onCancel();
        }
    }
    else
    {
        void (^handler)(void) = self.otherButtonHandlers[@(buttonIndex)];
        handler();
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.onCancel)
    {
        self.onCancel();
    }
    else if (alertView.cancelButtonIndex != -1)
    {
        [self alertView:alertView didDismissWithButtonIndex:alertView.cancelButtonIndex];
    }
}

@end
