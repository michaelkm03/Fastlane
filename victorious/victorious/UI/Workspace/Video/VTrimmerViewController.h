//
//  VTrimmerViewController.h
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import CoreMedia;

@interface VTrimmerViewController : UIViewController

@property (nonatomic, assign) CMTime minimumStartTime;
@property (nonatomic, assign) CMTime maximumEndTime;
@property (nonatomic, assign) CMTime maximumTrimDuration;

@property (nonatomic, readonly) CMTimeRange selectedTimeRange;

@end
