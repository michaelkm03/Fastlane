//
//  VFilterTool.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VHasManagedDependencies.h"
#import "VWorkspaceTool.h"

/**
 *  VFilterWorkspaceTool applies a filter in the rendering process. In the inspector it presents a ticker picker for selecting the current filter. On selection it updates VCanvasView's filter property. During rendering the filter will apply it's effects to the input image (these may involve compositing or simple filter operations).
 */
@interface VFilterTool : NSObject <VHasManagedDependancies, VWorkspaceTool>

@end
