//
//  VProfileCreateViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"

@class VUser;

@interface VProfileCreateViewController : UIViewController
@property (nonatomic, assign)   VLoginType      loginType;
@property (nonatomic, strong)   VUser*          profile;

@property (nonatomic, strong)   NSString*       accountEmail;
@property (nonatomic, strong)   NSString*       accountPassword;

@end
