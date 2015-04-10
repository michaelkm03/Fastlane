//
//  VContentViewAlertHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentViewAlertHelper.h"

@implementation VContentViewAlertHelper

- (UIAlertController *)alertForConfirmDiscardMediaWithDelete:(void(^)())onDelete cancel:(void(^)())onCancel
{
    // We already have a selected media does the user want to discard and re-take?
    NSString *actionSheetTitle = NSLocalizedString(@"Delete this content and select something else?", @"User has already selected media (pictire/video) as an attachment for commenting.");
    NSString *discardActionTitle = NSLocalizedString(@"Delete", @"Delete the previously selected item. This is a destructive operation.");
    NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Cancel button.");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:actionSheetTitle
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:discardActionTitle
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action)
                                   {
                                       if ( onDelete != nil )
                                       {
                                           onDelete();
                                       }
                                   }];
    [alertController addAction:deleteAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelActionTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
                                   {
                                       if ( onCancel != nil )
                                       {
                                           onCancel();
                                       }
                                   }];
    [alertController addAction:cancelAction];
    return alertController;
}

- (UIAlertController *)alertForNextSequenceErrorWithDismiss:(void(^)())onDismiss
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
