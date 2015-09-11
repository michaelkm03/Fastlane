//
//  VVideoPreviewView.h
//  victorious
//
//  Created by Patrick Lynch on 9/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@protocol VVideoPlayer;

@protocol VVideoPreviewView <NSObject>

@property (nonatomic, weak, readonly) id<VVideoPlayer> videoPlayer;

@end