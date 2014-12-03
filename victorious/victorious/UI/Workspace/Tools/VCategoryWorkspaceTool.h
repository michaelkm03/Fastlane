//
//  VCategoryWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VWorkspaceTool.h"
#import "VHasManagedDependencies.h"

@interface VCategoryWorkspaceTool : NSObject <VWorkspaceTool, VHasManagedDependancies>

@property (nonatomic, strong, readonly) NSArray *subTools; ///< The subtools if any for this tool

@property (nonatomic, strong, readonly) UIViewController *toolPicker;

@end
