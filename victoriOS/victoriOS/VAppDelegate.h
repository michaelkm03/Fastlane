//
//  VAppDelegate.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (VAppDelegate*) sharedAppDelegate;

@end
