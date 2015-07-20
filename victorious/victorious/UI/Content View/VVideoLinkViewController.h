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
