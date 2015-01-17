//
//  VStreamCellVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class AVPlayer;

@interface VStreamCellVideoView : UIView

- (void)setAssetURL:(NSURL *)assetURL;

- (void)play;

- (void)pause;

@end