//
//  VFirstTimeUserVideoViewController.h
//  victorious
//
//  Created by Lawrence Leach on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VFirstTimeUserVideoViewController : UIViewController

+ (VFirstTimeUserVideoViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

@property (nonatomic, strong) UIImage *imageSnapshot;

- (BOOL)hasBeenShown;

@end
