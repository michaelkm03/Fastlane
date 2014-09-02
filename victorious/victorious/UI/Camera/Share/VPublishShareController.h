//
//  VPublishShareController.h
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPublishShareView;

/**
 Abstract base class for objects that manage
 the sharing of newly published content
 */
@interface VPublishShareController : NSObject

@property (nonatomic, readonly) VPublishShareView *shareView; ///< The share view that is being managed by the receiver
@property (nonatomic, readonly, getter = isSelected) BOOL selected;  ///< YES if this share option has been authorized and selected by the user

/**
 This method can be overridden by subclasses
 to handle taps on the share button. Default
 implementation does nothing.
 */
- (void)shareButtonTapped;

@end
