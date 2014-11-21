//
//  VAlertControllerAdvanced.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAlertControllerAdvanced.h"

@interface VAlertControllerAdvanced()

@property (nonatomic, strong) NSMutableArray *actions;

@end

@implementation VAlertControllerAdvanced

#pragma mark - VAlertController overrides

- (void)addAction:(VAlertAction *)action
{
    NSParameterAssert( action != nil );
    
    if ( self.actions == nil )
    {
        self.actions = [[NSMutableArray alloc] init];
    }
    
    [self.actions addObject:action];
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                             message:self.message
                                                                      preferredStyle:[self systemStyleFromStyle:self.style]];
    alertController.view.tintColor = self.tintColor;
    
    for ( VAlertAction *action in self.actions )
    {
        UIAlertAction *systemAction = [self systemActionFromAction:action];
        [alertController addAction:systemAction];
    }
    
    [viewController presentViewController:alertController animated:animated completion:completion];
}

- (void)removeAllActions
{
    self.actions = nil;
}

#pragma mark - Helpers

- (UIAlertAction *)systemActionFromAction:(VAlertAction *)action
{
    UIAlertAction *systemAction = [UIAlertAction actionWithTitle:action.title
                                                           style:[self systemActionStyleFromActionStyle:action.style]
                                                         handler:^(UIAlertAction *systemAction)
                                   {
                                       [action execute];
                                   }];
    systemAction.enabled = action.enabled;
    return systemAction;
}

- (UIAlertControllerStyle)systemStyleFromStyle:(VAlertControllerStyle)style
{
    switch (style)
    {
        case VAlertControllerStyleActionSheet:
            return UIAlertControllerStyleActionSheet;
        case VAlertControllerStyleAlert:
            return UIAlertControllerStyleAlert;
    }
}

- (UIAlertActionStyle)systemActionStyleFromActionStyle:(VAlertActionStyle)style
{
    switch (style)
    {
        case VAlertActionStyleDefault:
            return UIAlertActionStyleDefault;
        case VAlertActionStyleDestructive:
            return UIAlertActionStyleDestructive;
        case VAlertActionStyleCancel:
            return UIAlertActionStyleCancel;
    }
}

@end