//
//  VVideoLinkViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMediaLinkViewController.h"

/**
    A media link view controller for displaying a video.
 */
@interface VVideoLinkViewController : VAbstractMediaLinkViewController

/**
 Sets the mediaUrl property and default value of the contentAspectRatio.
 
 @param url The url that media should be loaded from. Must not be nil.
 
 @return A VVideoLinkViewController.
 */
- (instancetype)initWithUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
    Whether or not the video should loop after completing. Defaults to NO.
 */
@property (nonatomic, assign) BOOL loop;

/**
    Whether or not the video should hide play controls at all times. Defaults to NO.
 */
@property (nonatomic, assign) BOOL hidePlayControls;

/**
    Whether or not the video should mute audio. Defaults to NO.
 */
@property (nonatomic, assign) BOOL muteAudio;

@end
