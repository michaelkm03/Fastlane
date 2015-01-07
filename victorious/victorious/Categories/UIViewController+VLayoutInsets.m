//
//  UIViewController+VLayoutInsets.m
//  victorious
//
//  Created by Josh Hinman on 1/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIViewController+VLayoutInsets.h"

#import <objc/runtime.h>

static const char kLayoutInsetsKey;

@implementation UIViewController (VLayoutInsets)

- (UIEdgeInsets)v_layoutInsets
{
    UIEdgeInsets layoutInsets = UIEdgeInsetsZero;
    NSValue *layoutInsetsValue = objc_getAssociatedObject(self, &kLayoutInsetsKey);
    
    if ( layoutInsetsValue != nil )
    {
        [layoutInsetsValue getValue:&layoutInsets];
    }
    return layoutInsets;
}

- (void)v_setLayoutInsets:(UIEdgeInsets)layoutInsets
{
    NSValue *layoutInsetsValue = [NSValue value:&layoutInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &kLayoutInsetsKey, layoutInsetsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
