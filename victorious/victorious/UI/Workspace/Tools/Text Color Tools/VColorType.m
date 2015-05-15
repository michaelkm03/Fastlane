//
//  VColorType.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VColorType.h"

@interface VColorType ()

@property (nonatomic, readwrite) UIColor *color;

@end

@implementation VColorType

@synthesize title = _title;

- (instancetype)initWithColor:(UIColor *)color title:(NSString *)title
{
    self = [super init];
    if (self)
    {
        _color = color;
        _title = title;
    }
    return self;
}

@end
