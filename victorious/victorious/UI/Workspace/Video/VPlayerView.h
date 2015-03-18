//
//  VPlayerView.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface VPlayerView : UIView

/**
 *  The designated initializer for this VPlayerView. Player must not be nil.
 */
- (instancetype)initWithPlayer:(AVPlayer *)player NS_DESIGNATED_INITIALIZER;

@end
