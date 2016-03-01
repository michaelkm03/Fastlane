//
//  VLargeNumberFormatter.m
//  victorious
//
//  Created by Josh Hinman on 6/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLargeNumberFormatter.h"

static const char kUnits[]    = { '\0', 'K', 'M', 'B' };
static const int  kMaxUnits   = sizeof kUnits - 1;
static const int  kMultiplier = 1000;

@interface VLargeNumberFormatter ()

@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation VLargeNumberFormatter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.formatter = [[NSNumberFormatter alloc] init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.formatter.roundingMode = NSNumberFormatterRoundDown;
        self.formatter.maximumFractionDigits = 1;
    }
    return self;
}

- (NSString *)stringForInteger:(NSInteger)integer
{
    int exponent = 0;
    Float64 decimalNumber = (Float64)integer;

    while ((decimalNumber >= kMultiplier) && (exponent < kMaxUnits))
    {
        decimalNumber /= kMultiplier;
        exponent++;
    }
    
    return [NSString stringWithFormat:@"%@%c", [self.formatter stringFromNumber:@(decimalNumber)], kUnits[exponent]];
}

@end
