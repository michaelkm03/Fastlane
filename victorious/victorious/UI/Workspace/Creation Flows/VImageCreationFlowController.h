//
//  VImageCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"
#import "VWorkspaceContext.h"

extern NSString * const VImageCreationFlowControllerKey;

@interface VImageCreationFlowController : VCreationFlowController

/**
 *  To force this image creation flow controller into remixing mode provide it with a previewImage 
 *  and mediaURL to use for remixing.
 */
- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL;

/**
 *  The context for image creation. Defualts to contentCreation.
 */
@property (nonatomic, assign) VWorkspaceFlowControllerContext context;

@end
