//
//  VQuoteWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VHasManagedDependencies.h"
#import "VWorkspaceTool.h"

/**
 *  VQuoteWorkspaceTool presents a canvasViewController with a UITextView subview that enables editing of quote text. When editing the textView is fully editable. During rendering the text is rendered in to an image and composited over the input image with CISourceOverCompositing preserving transparency to leave the image visible underneath the text.
 */
@interface VQuoteWorkspaceTool : NSObject <VHasManagedDependancies, VWorkspaceTool>

@end
