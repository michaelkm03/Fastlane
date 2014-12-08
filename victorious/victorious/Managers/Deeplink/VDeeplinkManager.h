//
//  VDeeplinkManager.h
//  victorious
//
//  Created by Will Long on 6/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VDeeplinkManagerInboxMessageNotification; ///< Posted for deep links that resolve to inbox messages

/**
 Analyze deep link URLs and perform appropriate actions
 */
@interface VDeeplinkManager : NSObject

@property (nonatomic, strong, readonly) NSURL *url; ///< The URL passed to the init method

/**
 Initializes a new instance of this class with a deep link
 */
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 Navigate to the item represented by the url
 */
- (void)performNavigation;

/**
 Post an appropriate notification for the url
 */
- (void)postNotification;

@end
