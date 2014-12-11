//
//  VCropWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VWorkspaceTool.h"
#import "VHasManagedDependencies.h"

/**
 *  VCropWorkspaceTool manages zooming/cropping of an image in the VCanvasView. While editing the crop tool updates the zoomScale/contentOffset of the canvasView's scrollView to reflect the current state of cropping. When rendering the crop tool will scale/crop the input image in a corresponding way to it's editing.
 */
@interface VCropWorkspaceTool : NSObject <VWorkspaceTool, VHasManagedDependancies>

@end
