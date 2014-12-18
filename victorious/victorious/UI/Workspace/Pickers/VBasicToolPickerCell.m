//
//  VBasicToolPickerCell.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBasicToolPickerCell.h"

@interface VBasicToolPickerCell ()

@property (nonatomic, weak, readwrite) IBOutlet UILabel *label;

@end

@implementation VBasicToolPickerCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 44.0f);
}

@end
