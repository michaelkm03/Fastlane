//
//  VTickerPickerViewController.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VToolPicker.h"

/**
 *  VTickerPickerViewController is a tool picker via conformance to the VToolPicker protocol. The ticker picker presents a list of items in a collection view with the item underneath the top position being the currently selected item.
 */
@interface VTickerPickerViewController : UICollectionViewController <VHasManagedDependencies, VToolPicker>

/**
 *  Tools can set this block to configure the label how they wish. If no block is provided label1 font and title of tool will be used.
 */
@property (nonatomic, copy) void (^configureItemLabel)(UILabel *labelInCell, id <VWorkspaceTool> tool);

@end
