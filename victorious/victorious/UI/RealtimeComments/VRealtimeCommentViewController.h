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

@property (nonatomic) CGFloat currentTime; ///Current time of the media
@property (nonatomic) CGFloat endTime;  ///End time of the media.  Defaults to CGFloatMax if not defined (to avoid divide by 0 crashes)

@end
