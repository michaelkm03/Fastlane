//
//  AVCaptureVideoPreviewLayer+VConvertPoint.h
//  victorious
//
//  Created by Josh Hinman on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureVideoPreviewLayer (VConvertPoint)

/**
 Converts from the receiver's coordinates to camera coordinates, where {0,0}
 represents the top left of the picture area, and {1,1} represents the
 bottom right in landscape mode with the home button on the right.
 
 @param viewPoint a CGPoint in the receiver's coordinate system
 @return a point between (0, 0) and (1, 1)
 */
- (CGPoint)v_convertPoint:(CGPoint)viewPoint;

@end
