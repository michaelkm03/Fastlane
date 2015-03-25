//
//  VTextPostConfiguration.m
//  victorious
//
//  Created by Patrick Lynch on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostConfiguration.h"

@implementation VTextPostConfiguration

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _lineHeightMultipler   = 1.6;
        _verticalSpacing       = 2;
        _lineOffsetMultiplier  = 0.4f;
        _horizontalSpacing     = 3;
        _maxTextLength         = 200;
        _backgroundColor       = [UIColor whiteColor];
    }
    return self;
}

@end
