//
//  VSideMenuViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VScaffoldViewController.h"

#import <UIKit/UIKit.h>

@class VNavigationController;

@interface VSideMenuViewController : VScaffoldViewController

@property (strong, readonly, nonatomic)  VNavigationController *contentViewController;

@end
