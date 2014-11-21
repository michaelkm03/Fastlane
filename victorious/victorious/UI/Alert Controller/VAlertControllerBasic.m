//
//  VAlertControllerBasic.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAlertControllerBasic.h"
#import "UIActionSheet+VBlocks.h"
#import "UIAlertView+VBlocks.h"

@interface VAlertControllerBasic ()

@property (nonatomic, strong) VAlertAction *cancelAction;
@property (nonatomic, strong) VAlertAction *destructiveAction;
@property (nonatomic, strong) NSMutableArray *defaultActions;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, readonly) UIActionSheet *actionSheet;

@end

@implementation VAlertControllerBasic

- (void)addAction:(VAlertAction *)action
{
    switch (action.style)
    {
        case VAlertActionStyleDestructive:
            self.destructiveAction = action;
            break;
            
        case VAlertActionStyleCancel:
            self.cancelAction = action;
            break;
            
        case VAlertActionStyleDefault:
        default:
            if ( self.defaultActions == nil )
            {
                self.defaultActions = [[NSMutableArray alloc] init];
            }
            [self.defaultActions addObject:action];
            break;
    }
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    if ( self.style == VAlertControllerStyleActionSheet )
    {
        [self.actionSheet showInView:viewController.view];
    }
    else if ( self.style == VAlertControllerStyleAlert )
    {
        [self.alertView show];
    }
}

- (UIActionSheet *)actionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.title
                                                    cancelButtonTitle:self.cancelAction != nil ? self.cancelAction.title : nil
                                                       onCancelButton:^void
                                  {
                                      if ( self.cancelAction != nil )
                                      {
                                          [self.cancelAction execute];
                                      }
                                  }
                                               destructiveButtonTitle:self.destructiveAction != nil ? self.destructiveAction.title : nil
                                                  onDestructiveButton:^void
                                  {
                                      if ( self.destructiveAction != nil )
                                      {
                                          [self.destructiveAction execute];
                                      }
                                  }
                                           otherButtonTitlesAndBlocks:nil];
    
    for ( VAlertAction *action in self.defaultActions )
    {
        [actionSheet addButtonWithTitle:action.title block:^void
         {
             [action execute];
         }];
    }
    
    return actionSheet;
}

- (UIAlertView *)alertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                        message:self.message
                                              cancelButtonTitle:self.cancelAction != nil ? self.cancelAction.title : nil
                                                 onCancelButton:^void
                              {
                                  if ( self.cancelAction != nil )
                                  {
                                      [self.cancelAction execute];
                                  }
                              }
                                     otherButtonTitlesAndBlocks:nil];
    
    for ( VAlertAction *action in self.defaultActions )
    {
        [alertView addButtonWithTitle:action.title block:^void
         {
             [action execute];
         }];
    }
    
    return alertView;
}

@end
