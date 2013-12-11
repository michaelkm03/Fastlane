//
//  VLoginViewController.h
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLoginViewController : UIViewController

+ (VLoginViewController *)sharedLoginViewController;

@property (nonatomic, readwrite, assign) BOOL    authorized;

@end
