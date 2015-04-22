//
//  VAbstractStreamCollectionCell.m
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionCell.h"

@implementation VAbstractStreamCollectionCell

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
{
    NSAssert(false, @"Must implement in subclasses!");
    return nil;
}

@end
