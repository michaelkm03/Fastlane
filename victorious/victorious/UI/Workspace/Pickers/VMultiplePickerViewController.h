//
//  VMultiplePickerViewController.h
//  victorious
//
//  Created by Patrick Lynch on 4/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VCollectionToolPicker.h"
#import "VMultipleToolPicker.h"

@interface VMultiplePickerViewController : UIViewController <VHasManagedDependencies, VMultipleToolPicker, VCollectionToolPicker>

@end
