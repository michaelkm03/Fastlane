//
//  VSeeMoreDirectoryItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

extern NSString * const VSeeMoreDirectoryItemCellNameStream;

@interface VSeeMoreDirectoryItemCell : VBaseCollectionViewCell

- (void)updateBottomConstraintToConstant:(CGFloat)constant;

@end
