//
//  VTickerPickerViewController.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VCollectionToolPicker.h"

/**
 *  VTickerPickerViewController is a tool picker via conformance to the VToolPicker protocol.
 *  The ticker picker presents a list of items in a collection view with the item underneath the
 *  top position being the currently selected item.
 */
@interface VTickerPickerViewController : UIViewController <VHasManagedDependencies, VCollectionToolPicker, VToolPicker>

@end
