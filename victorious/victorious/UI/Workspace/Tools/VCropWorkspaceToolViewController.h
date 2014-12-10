//
//  VCropWorkspaceToolViewController.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

@interface VCropWorkspaceToolViewController : UIViewController <VHasManagedDependancies>

+ (instancetype)cropViewController;

@property (nonatomic, copy) void (^onCropBoundsChange)(UIScrollView *croppingScrollView);

@property (nonatomic, assign) CGSize assetSize;

@property (nonatomic, weak, readonly) UIScrollView *croppingScrollView;

@end
