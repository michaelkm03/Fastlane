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

@interface VCropWorkspaceTool : NSObject <VWorkspaceTool, VHasManagedDependancies>

@property (nonatomic, copy) void (^onCropBoundsChange)(UIScrollView *croppingScrollView);

@property (nonatomic, assign) CGSize assetSize;

@end
