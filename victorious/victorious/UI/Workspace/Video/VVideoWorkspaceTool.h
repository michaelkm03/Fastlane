//
//  VVideoWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 1/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceTool.h"

@class VVideoPlayerView;

@protocol VVideoWorkspaceTool <VWorkspaceTool>

@optional

- (void)exportToURL:(NSURL *)url
     withCompletion:(void (^)(BOOL finished, UIImage *previewImage))completion;

@property (nonatomic, copy) NSURL *mediaURL;

@property (nonatomic, weak) VVideoPlayerView *playerView;

@end
