//
//  VBaseCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@implementation VBaseCollectionViewCell

#pragma mark - VSharedCollectionViewMethods

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

@end
