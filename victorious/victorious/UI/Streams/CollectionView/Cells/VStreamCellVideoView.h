//
//  VStreamCellVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VStreamCellVideoView;
@class AVPlayer;

@protocol VStreamCellVideoViewDelegtae <NSObject>

- (void)videoViewPlayerDidBecomeReady:(VStreamCellVideoView *)videoView;

@end

@interface VStreamCellVideoView : UIView

@property (nonatomic, strong) NSURL *itemURL;

@property (nonatomic, weak) id<VStreamCellVideoViewDelegtae> delegate;

- (void)setItemURL:(NSURL *)itemURL loop:(BOOL)loop audioMuted:(BOOL)audioMuted;

- (void)play;

- (void)pause;

@end