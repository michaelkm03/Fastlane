//
//  VCropWorkspaceToolViewController.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

/**
 *  A CropToolViewController contains a cropping scrollview that contains no visible subviews but forwards any updates of the contentOffset or zoomScale to interested parties via the onCropBoundsChange block.
 */
@interface VCropWorkspaceToolViewController : UIViewController <VHasManagedDependancies>

+ (instancetype)cropViewController;

@property (nonatomic, copy) void (^onCropBoundsChange)(UIScrollView *croppingScrollView); ///< Will be called on content offset or zoom scale changes

@property (nonatomic, assign) CGSize assetSize; ///< The asset size (in points) that the cropVC will provide scrolling area for.

@property (nonatomic, weak, readonly) UIScrollView *croppingScrollView; ///< The cropping scrollView used internally for scrolling/zooming.

@end
