//
//  VCoachmarkDisplayResponder.h
//  victorious
//
//  Created by Sharif Ahmed on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VMenuItemDiscoveryBlock) (BOOL found, CGRect location);

@protocol VCoachmarkDisplayResponder <NSObject>

/**
    Implementers of this method should return the absolute frame of a button
    representing the screen with the provided identifier. If no screen is found,
    implementers should attempt to call this method on the next responder.
 
    @param identifier The identifier of the screen whose menu button that should be located.
    @param completion The block that should be called on after a menu button is located.
 */
@required
- (void)findOnScreenMenuItemWithIdentifier:(NSString *)identifier andCompletion:(VMenuItemDiscoveryBlock)completion;

@end
