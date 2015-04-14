//
//  VActionBarFixedWidthItem.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionBarFixedWidthItem.h"
#import "UIView+Autolayout.h"

@interface VActionBarFixedWidthItem ()

@property (nonatomic, assign, readwrite) CGFloat width;

@end

@implementation VActionBarFixedWidthItem

+ (VActionBarFixedWidthItem *)fixedWidthItemWithWidth:(CGFloat)width
{
    VActionBarFixedWidthItem *fixedWidthItem = [[VActionBarFixedWidthItem alloc] initWithFrame:CGRectZero];
    fixedWidthItem.width = width;
    fixedWidthItem.translatesAutoresizingMaskIntoConstraints = NO;
    [fixedWidthItem v_addWidthConstraint:width];
    return fixedWidthItem;
}

@end
