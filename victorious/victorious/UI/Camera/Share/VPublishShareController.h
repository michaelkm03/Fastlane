//
//  VPublishShareController.h
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Abstract base class for objects that manage
 the sharing of newly published content
 */
@interface VPublishShareController : NSObject

/**
 *  The switch to configure defaults/enabled states for.
 */
@property (nonatomic, weak) UISwitch *switchToConfigure;

/**
 This method can be overridden by subclasses
 to handle taps on the share button. Default
 implementation does nothing.
 */
- (void)shareButtonTapped;

@end
