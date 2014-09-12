//
//  VSectionHandleReusableView.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSectionHandleReusableView.h"

@implementation VSectionHandleReusableView

+ (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 20.0f);
}

@end
