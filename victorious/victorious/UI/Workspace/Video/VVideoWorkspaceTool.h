//
//  VVideoWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 1/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"

@protocol VVideoWorkspaceTool <VWorkspaceTool>

@optional

/**
 *  All VideoWorkspaceTools must implement this for exporting.
 */
- (void)exportToURL:(NSURL *)url
     withCompletion:(void (^)(BOOL finished, UIImage *previewImage))completion;

/**
 *  A media item for use while editing.
 */
@property (nonatomic, copy) NSURL *mediaURL;

@end
