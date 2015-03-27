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
@interface VCropToolViewController : UIViewController <VHasManagedDependencies>

+ (instancetype)cropViewController;

@end
