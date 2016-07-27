//
//  VCellSizeComponent.m
//  victorious
//
//  Created by Patrick Lynch on 6/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCellSizeComponent.h"

@implementation VCellSizeComponent

- (instancetype)initWithConstantSize:(CGSize)constantSize dynamicSize:(VDynamicCellSizeBlock)dynamicSize
{
    self = [super init];
    if ( self != nil )
    {
        _constantSize = constantSize;
        _dynamicSize = [dynamicSize copy];
    }
    return self;
}

@end
