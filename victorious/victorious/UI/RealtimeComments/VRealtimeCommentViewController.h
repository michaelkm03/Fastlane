//
//  VRealtimeCommentViewController.h
//  victorious
//
//  Created by Will Long on 7/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface VRealtimeCommentViewController : UIViewController

@property (nonatomic, strong) NSArray* comments;

@property (nonatomic) CMTime currentTime;
@property (nonatomic) CMTime endTime;

@end
