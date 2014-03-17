//
//  VRemixTrimViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VAbstractVideoEditorViewController.h"

@interface VRemixTrimViewController : VAbstractVideoEditorViewController

+ (UIViewController *)remixViewControllerWithAsset:(AVURLAsset *)asset;

@end
