//
//  VActionSheetViewController.h
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VActionItem.h"

@interface VActionSheetViewController : UIViewController

+ (VActionSheetViewController *)actionSheetViewController;

- (void)addActionItems:(NSArray *)actionItems;

@property (nonatomic, copy) void (^cancelHandler)(void);

@end
