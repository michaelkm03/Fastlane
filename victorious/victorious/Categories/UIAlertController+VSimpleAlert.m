//
//  UIAlertController+VSimpleAlert.m
//  victorious
//
//  Created by Michael Sena on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIAlertController+VSimpleAlert.h"

@implementation UIAlertController (VSimpleAlert)

+ (instancetype)simpleAlertControllerWithTitle:(NSString *)title
                                       message:(NSString *)message
                          andCancelButtonTitle:(NSString *)cancelButtontitle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtontitle style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    return alertController;
}

@end
