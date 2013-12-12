//
//  VLoginViewController.h
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUser.h"

@interface VLoginViewController : UIViewController

+ (VLoginViewController *)sharedLoginViewController;

@property (nonatomic, readonly) BOOL    authorized;
@property (nonatomic, readonly, strong) VUser* mainUser;

@end
