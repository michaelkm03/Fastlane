//
//  VMonetizationManagerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAdVideoPlayerViewController.h"
#import "VCVideoPlayerViewController.h"


@interface VMonetizationManagerViewController : UIViewController

@property (nonatomic, strong, readwrite) VCVideoPlayerViewController *contentVideoPlayer;
@property (nonatomic, strong) VAdVideoPlayerViewController *adVideoPlayer;

@end
