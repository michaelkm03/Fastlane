//
//  VDirectoryItemCell.h
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDirectoryItem;

extern NSString * const kVStreamDirectoryItemCellName;

@interface VDirectoryItemCell : UICollectionViewCell

@property (nonatomic, strong) VDirectoryItem* directoryItem;

@end
