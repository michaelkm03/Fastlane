//
//  VTrimLoopingPlayerViewController.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreMedia;

@interface VTrimLoopingPlayerViewController : UIViewController

@property (nonatomic, copy) NSURL *mediaURL;

@property (nonatomic, assign) CMTimeRange trimRange;

@end
