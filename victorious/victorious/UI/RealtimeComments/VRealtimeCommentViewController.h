//
//  VRealtimeCommentViewController.h
//  victorious
//
//  Created by Will Long on 7/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@protocol VRealtimeCommentDelegate <NSObject>

- (void)willShowRTCMedia;
- (void)didFinishedRTCMedia;

@end

@interface VRealtimeCommentViewController : UIViewController

@property (nonatomic, weak) id<VRealtimeCommentDelegate> delegate;

@property (nonatomic, strong) NSArray* comments;

@property (nonatomic) CGFloat currentTime; ///Current time of the media
@property (nonatomic) CGFloat endTime;  ///End time of the media.  Defaults to CGFloatMax if not defined (to avoid divide by 0 crashes)

@property (nonatomic, weak, readonly) IBOutlet UIView* commentBackgroundView;
@property (nonatomic, weak, readonly) IBOutlet UIImageView* arrowImageView;
@end
