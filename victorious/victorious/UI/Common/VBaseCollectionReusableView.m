//
//  VBaseCollectionReusableView.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionReusableView.h"

@implementation VBaseCollectionReusableView

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}


@end
