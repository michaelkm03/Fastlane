//
//  VAlertControllerAdvanced.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAlertControllerAdvanced.h"

@interface VAlertControllerAdvanced()

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation VAlertControllerAdvanced

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style
{
    self = [super init];
    if (self)
    {
        UIAlertControllerStyle preferredStyle = [self styleFromStyle:style];
        self.alertController = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:preferredStyle];
    }
    return self;
}

#pragma mark - VAlertController Protocol

- (void)addAction:(VAlertAction *)action
{
    NSParameterAssert( self.alertController != nil );
    NSParameterAssert( action != nil );
    
    [self.alertController addAction:[self actionFromAction:action]];
}

- (void)presentInViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    NSParameterAssert( self.alertController != nil );
    
    [viewController presentViewController:self.alertController animated:animated completion:completion];
}

#pragma mark - Helpers

- (UIAlertAction *)actionFromAction:(VAlertAction *)action
{
    return [UIAlertAction actionWithTitle:action.title
                                    style:[self actionStyleFromStyle:action.style]
                                  handler:^(UIAlertAction *alertAction)
            {
                [action execute];
            }];
}

- (UIAlertControllerStyle)styleFromStyle:(VAlertControllerStyle)style
{
    switch (style)
    {
        case VAlertControllerStyleActionSheet:
            return UIAlertControllerStyleActionSheet;
        case VAlertControllerStyleAlert:
            return UIAlertControllerStyleAlert;
    }
}

- (UIAlertActionStyle)actionStyleFromStyle:(VAlertActionStyle)style
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