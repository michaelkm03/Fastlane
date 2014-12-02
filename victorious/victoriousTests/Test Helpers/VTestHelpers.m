//
//  VTestHelpers.m
//  victorious
//
//  Created by Patrick Lynch on 11/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTestHelpers.h"

BOOL randomBool() {
    return arc4random() % 2 == 0;
}

NSIndexPath *VIndexPathMake( NSInteger row, NSInteger section ) {
    return [NSIndexPath indexPathForRow:row inSection:section];
}
