//
//  VOwnerViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VComposeMessageViewController.h"

@protocol VComposePollDelegate <NSObject>
@end

@interface VOwnerViewController : VComposeMessageViewController <UITextFieldDelegate, UIImagePickerControllerDelegate>

@end
