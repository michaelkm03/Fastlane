//
//  VStreamContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VStreamTableViewController.h"

@interface VStreamContainerViewController : UIViewController <VStreamTableDelegate>

@property (nonatomic, readonly) VStreamTableViewController* streamTable;

+ (instancetype)containerForStreamTable:(VStreamTableViewController*)streamTable;

@end
