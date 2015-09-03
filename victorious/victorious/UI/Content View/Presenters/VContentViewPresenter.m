//
//  VContentViewPresenter.m
//  victorious
//
//  Created by Tian Lan on 7/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentViewPresenter.h"
#import "VContentViewFactory.h"

@implementation VContentViewPresenter

+ (void)presentContentViewFromViewController:(UIViewController *)viewController
                       withDependencyManager:(VDependencyManager *)dependencyManager
                                 ForSequence:(VSequence *)sequence
                              inStreamWithID:(NSString *)streamId
                                   commentID:(NSNumber *)commentID
                            withPreviewImage:(UIImage *)previewImage
{
    VContentViewFactory *contentViewFactory = [dependencyManager contentViewFactory];
    
    NSString *reason = nil;
    if ( ![contentViewFactory canDisplaySequence:sequence localizedReason:&reason] )
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:reason preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil]];
        [viewController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIViewController *contentView = [contentViewFactory contentViewForSequence:sequence inStreamWithID:streamId commentID:commentID placeholderImage:previewImage];
    if ( contentView != nil )
    {
        if ( viewController.presentedViewController )
        {
            [viewController dismissViewControllerAnimated:NO completion:nil];
        }
        
        [viewController presentViewController:contentView animated:YES completion:nil];
    }
}

@end
