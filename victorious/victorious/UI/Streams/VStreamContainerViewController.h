//
//  VStreamContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VStreamTableViewController.h"
#import "VTableContainerViewController.h"

@interface VStreamContainerViewController : VTableContainerViewController <VStreamTableDelegate>

@property (nonatomic, readonly) VStreamTableViewController *streamTable;
@property (nonatomic, assign) BOOL shouldShowHeaderLogo;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, assign) BOOL shouldShowUploadProgress; ///< This must be set to YES prior to the view being loaded, otherwise it has no effect. Default is NO.

+ (instancetype)containerForStreamTable:(VStreamTableViewController *)streamTable;
+ (instancetype)modalContainerForStreamTable:(VStreamTableViewController *)streamTable;

@end
