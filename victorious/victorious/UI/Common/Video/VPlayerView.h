//
//  VPlayerView.h
//  victorious
//
//  Created by Michael Sena on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface VPlayerView : UIView

- (instancetype)initWithPlayer:(AVPlayer *)player;

@end
