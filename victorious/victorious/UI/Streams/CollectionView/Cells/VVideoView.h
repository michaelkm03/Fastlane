//
//  VVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VVideoView;
@class AVPlayer;

@protocol VVideoViewDelegtae <NSObject>

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView;

@end

@interface VVideoView : UIView

@property (nonatomic, strong) NSURL *itemURL;

@property (nonatomic, weak) id<VVideoViewDelegtae> delegate;

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted;

- (void)play;

- (void)pause;

@end