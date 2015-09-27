//
//  VContentAlertHelper.m
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VContentAlertHelper.h"

@implementation VContentAlertHelper

+ (UIAlertController *)alertForNextSequenceErrorWithDismiss:(void(^)())onDismiss
{
    NSString *title = NSLocalizedString( @"Error Loading Next Video", @"" );
    NSString *message = NSLocalizedString( @"TryAgain", @"" );
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", nil )
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
                                   {
                                       if ( onDismiss != nil )
                                       {
                                           onDismiss();
                                       }
                                   }];
    [alertController addAction:cancelAction];
    return alertController;
}

@end
