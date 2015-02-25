//
//  VTranslucentBackground.h
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBackground.h"

/**
 *  A Translucent background. Elements should be placed underneath
    so that they can scroll and show through.
 */
@interface VTranslucentBackground : VBackground

/**
 *  Use this to configure any tabBars or toolBars where appropriate.
 */
- (UIBarStyle)barStyleForTranslucentBackground;

@end
