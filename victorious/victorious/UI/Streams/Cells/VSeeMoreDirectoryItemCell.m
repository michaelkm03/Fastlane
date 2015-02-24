//
//  VSeeMoreDirectoryItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSeeMoreDirectoryItemCell.h"

NSString * const VSeeMoreDirectoryItemCellNameStream = @"VStreamSeeMoreDirectoryItemCell";

@interface VSeeMoreDirectoryItemCell ()

@property (nonatomic, weak)IBOutlet NSLayoutConstraint *bottomConstriant;

@end

@implementation VSeeMoreDirectoryItemCell

- (void)updateBottomConstraintToConstant:(CGFloat)constant
{
    if( self.bottomConstriant.constant != constant )
    {
        self.bottomConstriant.constant = constant;
        [self layoutIfNeeded];
    }
}

@end
