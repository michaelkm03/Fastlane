//
//  UIAlertView+VBlocks.m
//  victorious
//
//  Created by Josh Hinman on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIAlertView+VBlocks.h"
#import "VAlertViewBlockDelegate.h"

#import <objc/runtime.h>

static const char kAssociatedObjectKey;

@implementation UIAlertView (VBlocks)

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle onCancelButton:(void(^)(void))cancelBlock otherButtonTitlesAndBlocks:(id)firstButtonTitle, ...
{
    VAlertViewBlockDelegate *delegate = [[VAlertViewBlockDelegate alloc] initWithCancelBlock:cancelBlock];
    self = [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self)
    {
        objc_setAssociatedObject(self, &kAssociatedObjectKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        va_list buttonTitles;
        va_start(buttonTitles, firstButtonTitle);
        for (id buttonTitle = firstButtonTitle; buttonTitle != nil; buttonTitle = va_arg(buttonTitles, NSString *))
        {
            void (^handler)(void) = va_arg(buttonTitles, void (^)(void));
            NSInteger index = [self addButtonWithTitle:buttonTitle];
            delegate.otherButtonHandlers[@(index)] = [handler copy];
        }
        va_end(buttonTitles);
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)(void))block
{
    VAlertViewBlockDelegate *delegate = objc_getAssociatedObject(self, &kAssociatedObjectKey);
    if (delegate)
    {
        NSInteger index = [self addButtonWithTitle:title];
        delegate.otherButtonHandlers[@(index)] = [block copy];
    }
}

@end
