//
//  NSURL+Validator.m
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+Validator.h"

@implementation NSURL (Validator)

- (BOOL)isValidURL
{
    return ![self.absoluteString isEqualToString:@""];
}

@end
