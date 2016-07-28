//
//  VCellSizeComponent.h
//  victorious
//
//  Created by Patrick Lynch on 6/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A block that is called during cell sizing (`totalSizeWithBaseSize:userInof:`) and
 defined usually during the initialization of a collection view cell's UI.
 Calculates a size that is determined by some unique aspects of a cell according to
 the specified user info that is passed in.
 */
typedef CGSize(^VDynamicCellSizeBlock)(CGSize, NSDictionary *userInfo);

/**
 A model object used internally to store constant size values and dynamic size blocks
 used later on by VCellSizeCollection to calculate sizes for collection view cells.
 */
@interface VCellSizeComponent : NSObject

- (instancetype)initWithConstantSize:(CGSize)constantSize dynamicSize:(VDynamicCellSizeBlock)dynamicSize;

/**
 A constant size which will never change depending on the content
 of the cell or its subcomponents.
 */
@property (nonatomic, assign, readonly) CGSize constantSize;

/**
 A block that calculates size based on some content in the cell.
 */
@property (nonatomic, copy, readonly) VDynamicCellSizeBlock dynamicSize;

@end
