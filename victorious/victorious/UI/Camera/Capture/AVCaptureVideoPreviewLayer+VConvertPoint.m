//
//  AVCaptureVideoPreviewLayer+VConvertPoint.m
//  victorious
//
//  Created by Josh Hinman on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "AVCaptureVideoPreviewLayer+VConvertPoint.h"

@implementation AVCaptureVideoPreviewLayer (VConvertPoint)

- (CGPoint)v_convertPoint:(CGPoint)viewPoint
{
    CGPoint cameraPoint;
    CGSize boundsSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));

    if ([self.connection isVideoMirrored])
    {
        viewPoint.x = CGRectGetWidth(self.bounds) - viewPoint.x;
    }
    
    if ([self.videoGravity isEqualToString:AVLayerVideoGravityResize])
    {
		// Scale, switch x and y, and reverse x
        cameraPoint = CGPointMake(viewPoint.y / boundsSize.height, 1.0f - (viewPoint.x / boundsSize.width));
    }
    else
    {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in self.connection.inputPorts)
        {
            if ([port mediaType] == AVMediaTypeVideo)
            {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewPoint;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = boundsSize.width / boundsSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ([self.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect])
                {
                    if (viewRatio > apertureRatio)
                    {
                        CGFloat y2 = boundsSize.height;
                        CGFloat x2 = boundsSize.height * apertureRatio;
                        CGFloat x1 = boundsSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2)
                        {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    }
                    else
                    {
                        CGFloat y2 = boundsSize.width / apertureRatio;
                        CGFloat y1 = boundsSize.height;
                        CGFloat x2 = boundsSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2)
                        {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                }
                else if ([self.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill])
                {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio)
                    {
                        CGFloat y2 = apertureSize.width * (boundsSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - boundsSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (boundsSize.width - point.x) / boundsSize.width;
                    }
                    else
                    {
                        CGFloat x2 = apertureSize.height * (boundsSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - boundsSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / boundsSize.height;
                    }
                }
                
                cameraPoint = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return cameraPoint;
}

@end
