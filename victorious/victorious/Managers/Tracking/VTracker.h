//
//  VTracker.h
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 Defines a singleton object that can perform some basic tracking functions.
 */
@protocol VTracker <NSObject>

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

@end
