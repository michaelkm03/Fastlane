//
//  VDirectoryItemCell.h
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VBaseCollectionViewCell.h"

@class VStreamItem;

extern NSString * const kVStreamDirectoryItemCellName;

@interface VDirectoryItemCell : VBaseCollectionViewCell

@property (nonatomic, strong) VStreamItem *streamItem;

@end
