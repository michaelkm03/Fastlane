//
//  VCanvasView.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VPhotoFilter.h"

/*
 VCanvasView is a representation of the current state of the workspace while editing an image.
 */
@interface VCanvasView : UIView

@property (nonatomic, strong) UIImage *sourceImage; ///< The image to use as the base of the canvas.

@property (nonatomic, strong) VPhotoFilter *filter; ///< The Filter to use on the image.

@property (nonatomic, readonly) UIScrollView *canvasScrollView; ///< A zooming scrollview for providing crop functionality.

@end
